# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# PackageKit supports 3.2+, but entropy and portage backends are untested
# Future note: use --enable-python3
PYTHON_COMPAT=( python2_7 )

inherit eutils autotools multilib python-single-r1 nsplugins bash-completion-r1

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Manage packages in a secure way using a cross-distro and cross-architecture API"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI="http://www.packagekit.org/releases/${MY_P}.tar.xz
	http://dev.gentoo.org/~lxnay/packagekit/${PN}-0.8.14.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~x86"
IUSE="connman cron command-not-found doc +introspection networkmanager nsplugin pm-utils entropy static-libs systemd test udev"

CDEPEND="connman? ( net-misc/connman )
	introspection? ( >=dev-libs/gobject-introspection-0.9.9[${PYTHON_USEDEP}] )
	networkmanager? ( >=net-misc/networkmanager-0.6.4 )
	nsplugin? (
		>=dev-libs/nspr-4.8
		x11-libs/cairo
		>=x11-libs/gtk+-2.14.0:2
		x11-libs/pango
	)
	udev? ( virtual/udev[gudev] )
	dev-db/sqlite:3
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.32.0:2[${PYTHON_USEDEP}]
	>=sys-auth/polkit-0.98
	>=sys-apps/dbus-1.3.0[${PYTHON_USEDEP}]
	${PYTHON_DEPS}"
DEPEND="${CDEPEND}
	doc? ( dev-util/gtk-doc[${PYTHON_USEDEP}] )
	nsplugin? ( >=net-misc/npapi-sdk-0.27 )
	systemd? ( >=sys-apps/systemd-204 )
	dev-libs/libxslt[${PYTHON_USEDEP}]
	>=dev-util/intltool-0.35.0
	virtual/pkgconfig
	sys-devel/gettext"

RDEPEND="${CDEPEND}
	entropy? ( >=sys-apps/entropy-234[${PYTHON_USEDEP}] )
	pm-utils? ( sys-power/pm-utils )
	>=app-portage/layman-1.2.3[${PYTHON_USEDEP}]
	>=sys-apps/portage-2.2[${PYTHON_USEDEP}]"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

APP_LINGUAS="as bg bn ca cs da de el en_GB es fi fr gu he hi hu it ja kn ko ml mr
ms nb nl or pa pl pt pt_BR ro ru sk sr sr@latin sv ta te th tr uk zh_CN zh_TW"
for X in ${APP_LINGUAS}; do
	IUSE=" ${IUSE} linguas_${X}"
done

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Stuff that will appear in 0.8.14
	EPATCH_EXCLUDE="
		0001-trivial-post-release-version-bump.patch
		0002-trivial-Update-the-example-spec-file-to-reflect-real.patch
		0003-zif-Remove-the-backend-as-nearly-all-functionality-i.patch
	"
	epatch "${WORKDIR}/${PN}-0.8.14/"*.patch
	epatch "${FILESDIR}"/${P}-entropy-fix-package-path.patch

	epatch "${FILESDIR}"/${PN}-0.8.x-npapi-sdk.patch #383141

	epatch_user

	# npapi-sdk patch and epatch_user
	eautoreconf
}

src_configure() {
	econf \
		$(test -n "${LINGUAS}" && echo -n "--enable-nls" || echo -n "--disable-nls") \
		--enable-introspection=$(use introspection && echo -n "yes" || echo -n "no") \
		--localstatedir=/var \
		--enable-bash-completion \
		--disable-dependency-tracking \
		--enable-option-checking \
		--enable-libtool-lock \
		--disable-strict \
		--disable-local \
		--with-default-backend=$(use entropy && echo -n "entropy" || echo -n "portage") \
		--with-security-framework=polkit \
		$(use_enable doc gtk-doc) \
		$(use_enable command-not-found) \
		--disable-debuginfo-install \
		--disable-gstreamer-plugin \
		--disable-service-packs \
		--enable-man-pages \
		--enable-portage \
		$(use_enable entropy) \
		$(use_enable cron) \
		--disable-gtk-module \
		$(use_enable introspection) \
		$(use_enable networkmanager) \
		$(use_enable nsplugin browser-plugin) \
		$(use_enable pm-utils) \
		$(use_enable static-libs static) \
		$(use_enable systemd) \
		$(use_enable systemd systemd-updates) \
		$(use_enable test tests) \
		$(use_enable udev device-rebind) \
		$(use_enable connman)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS MAINTAINERS NEWS README TODO || die "dodoc failed"
	dodoc ChangeLog || die "dodoc failed"

	if use nsplugin; then
		dodir "/usr/$(get_libdir)/${PLUGINS_DIR}"
		mv "${D}/usr/$(get_libdir)/mozilla/plugins"/* \
			"${D}/usr/$(get_libdir)/${PLUGINS_DIR}/" || die
	fi

	if ! use static-libs; then
		prune_libtool_files --all
	fi
}
