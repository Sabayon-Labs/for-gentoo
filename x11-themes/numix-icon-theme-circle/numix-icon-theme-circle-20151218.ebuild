# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit git-r3
DESCRIPTION="Official icon theme circle from the Numix project."
HOMEPAGE="https://numixproject.org"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/numixproject/${PN}.git"
	KEYWORDS=""
else
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/numixproject/${PN}.git"
	EGIT_COMMIT="d0ee7b1a290d04f8ba80fc6a131751c7d519cf5f"
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="GPL-3+"
SLOT="0"

DEPEND="x11-themes/numix-icon-theme"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/share/icons
	doins -r Numix-Circle Numix-Circle-Light
	dodoc readme.md
}
