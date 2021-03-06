# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit flag-o-matic libtool multilib

MY_P=pkg-config-${PV}

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/pkg-config"
	inherit autotools git-2
else
	KEYWORDS="amd64 x86"
	SRC_URI="http://pkgconfig.freedesktop.org/releases/${MY_P}.tar.gz"
fi

DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"

LICENSE="GPL-2"
SLOT="0"
IUSE="elibc_FreeBSD elibc_glibc hardened internal-glib"

RDEPEND="!internal-glib? ( >=dev-libs/glib-2.30 )
	!dev-util/pkgconf[pkg-config]
	!dev-util/pkg-config-lite
	!dev-util/pkgconfig-openbsd[pkg-config]"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

DOCS=( AUTHORS NEWS README )

src_prepare() {
	sed -i -e "s|^prefix=/usr\$|prefix=${EPREFIX}/usr|" check/simple.pc || die #434320

	if [[ ${PV} == *9999* ]]; then
		eautoreconf
	else
		elibtoolize # Required for FreeMiNT wrt #333429
	fi
}

src_configure() {
	local myconf

	if use internal-glib; then
		myconf+=' --with-internal-glib'
		# non-glibc platforms use GNU libiconv, but configure needs to
		# know about that not to get confused when it finds something
		# outside the prefix too
		if use prefix && use !elibc_glibc ; then
			myconf+=" --with-libiconv=gnu"
			# add the libdir for libtool, otherwise it'll make love with system
			# installed libiconv
			append-ldflags "-L${EPREFIX}/usr/$(get_libdir)"
		fi
	else
		if ! has_version dev-util/pkgconfig; then
			export GLIB_CFLAGS="-I${EPREFIX}/usr/include/glib-2.0 -I${EPREFIX}/usr/$(get_libdir)/glib-2.0/include"
			export GLIB_LIBS="-lglib-2.0"
		fi
	fi

	use ppc64 && use hardened && replace-flags -O[2-3] -O1

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	use elibc_FreeBSD && myconf+=' --enable-indirect-deps'

	[[ ${PV} == *9999* ]] && myconf+=' --enable-maintainer-mode'

	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-system-include-path="${EPREFIX}"/usr/include \
		--with-system-library-path="${EPREFIX}"/usr/$(get_libdir) \
		${myconf}
}

src_install() {
	default

	if use prefix; then
		# Add an explicit reference to $EPREFIX to PKG_CONFIG_PATH to
		# simplify cross-prefix builds
		echo "PKG_CONFIG_PATH=${EPREFIX}/usr/$(get_libdir)/pkgconfig:${EPREFIX}/usr/share/pkgconfig" >> "${T}"/99${PN}
		doenvd "${T}"/99${PN}
	fi
}
