# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
LANGS="ru"

inherit eutils qt4-r2

MY_P="${P}-src"

DESCRIPTION="Advanced text editor with syntax highlighting"
HOMEPAGE="http://qt-apps.org/content/show.php/QWriter?content=106377"
#upstream failed to provide a sane url
SRC_URI="https://qwriter.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtgui:4
	>=x11-libs/qscintilla-2.10:=[qt4(-)]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i "s:languages:/usr/share/${PN}/languages:" src/MainWindow.cpp \
		|| die "failed to fix translation path"
	# gcc-4.7. Bug #425252
	epatch \
		"${FILESDIR}"/${P}-gcc47.patch \
		"${FILESDIR}"/qscintilla-2.10.patch
	qt4-r2_src_prepare
}

src_install() {
	dobin bin/${PN}
	newicon images/w.png ${PN}.png
	make_desktop_entry ${PN} QWriter ${PN}
	insinto /usr/share/${PN}/languages/
	for x in ${LANGS};do
		for j in ${LINGUAS};do
			if [[ $x == $j ]]; then
				doins languages/${PN}_$x.qm
			fi
		done
	done
}