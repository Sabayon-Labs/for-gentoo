# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils autotools git-r3

DESCRIPTION="Capability DO (like a sudo providing users with just the capabilities they need)"
HOMEPAGE="https://github.com/rd235/cado"
EGIT_REPO_URI="https://github.com/rd235/${PN}"
EGIT_COMMIT="06152520a022539c82919d7267085ee1e7ef3beb"
KEYWORDS="~amd64 ~x86 ~arm"

SLOT="0"
LICENSE="GPL-2"
RDEPEND=""
DEPEND=""

src_prepare() {
	eapply_user
	eautoreconf
}

src_install() {
	dobin ${PN}
	dobin caprint
	doman *.1
}
