# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils

DESCRIPTION="Manages the /usr/bin/vi symlink"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/vi.eselect-${PV}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.6"

src_prepare() {
	epatch "${FILESDIR}/${P}-prefix.patch"
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/vi.eselect-${PV}" vi.eselect || die
}
