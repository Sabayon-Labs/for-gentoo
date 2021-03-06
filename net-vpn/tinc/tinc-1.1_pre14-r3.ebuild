# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

MY_PV=${PV/_/}
MY_P=${PN}-${MY_PV}

PYTHON_COMPAT=( python2_7 )

inherit eutils multilib python-single-r1

DESCRIPTION="tinc is an easy to configure VPN implementation"
HOMEPAGE="http://www.tinc-vpn.org/"

UPSTREAM_VER=1

[[ -n ${UPSTREAM_VER} ]] && \
	UPSTREAM_PATCHSET_URI="https://dev.gentoo.org/~dlan/distfiles/${PN}-1.1-upstream-patches-${UPSTREAM_VER}.tar.xz"

SRC_URI="http://www.tinc-vpn.org/packages/${MY_P}.tar.gz
	${UPSTREAM_PATCHSET_URI}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+lzo +ncurses gui libressl +readline +ssl uml vde upnp +zlib"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	gui? ( dev-python/wxpython:3.0[${PYTHON_USEDEP}] )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	lzo? ( dev-libs/lzo:2 )
	ncurses? ( sys-libs/ncurses:= )
	readline? ( sys-libs/readline:= )
	upnp? ( net-libs/miniupnpc )
	zlib? ( sys-libs/zlib )"
RDEPEND="${DEPEND}
	vde? ( net-misc/vde )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Upstream's patchset
	if [[ -n ${UPSTREAM_VER} ]]; then
		einfo "Try to apply Tinc Upstream patch set"
		EPATCH_SUFFIX="patch" \
		EPATCH_FORCE="yes" \
		EPATCH_OPTS="-p1" \
			epatch "${WORKDIR}"/patches-upstream
	fi

	eapply "${FILESDIR}"/tinc-1.1-fix-paths.patch #560528

	# Sabayon mod.
	eapply "${FILESDIR}"/tinc-1.1-tinfo-link.patch #621868

	eapply_user
}

src_configure() {
	econf \
		--enable-jumbograms \
		--disable-silent-rules \
		--enable-legacy-protocol \
		--disable-tunemu  \
		--with-systemd=/usr/$(get_libdir)/systemd/system \
		$(use_enable lzo) \
		$(use_enable ncurses curses) \
		$(use_enable readline) \
		$(use_enable uml) \
		$(use_enable vde) \
		$(use_enable zlib) \
		$(use_enable upnp miniupnpc) \
		$(use_with ssl openssl)
		#--without-libgcrypt \
}

src_install() {
	emake DESTDIR="${D}" install
	dodir /etc/tinc
	dodoc AUTHORS NEWS README THANKS
	doconfd "${FILESDIR}"/tinc.networks
	newconfd "${FILESDIR}"/tincd.conf tincd
	newinitd "${FILESDIR}"/tincd-r2 tincd

	if use gui; then
		python_fix_shebang "${ED}"/usr/bin/tinc-gui
	else
		rm -f "${ED}"/usr/bin/tinc-gui || die
	fi
}

pkg_postinst() {
	elog "This package requires the tun/tap kernel device."
	elog "Look at http://www.tinc-vpn.org/ for how to configure tinc"
}
