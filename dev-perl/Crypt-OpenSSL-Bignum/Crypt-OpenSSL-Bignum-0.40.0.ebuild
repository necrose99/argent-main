# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MODULE_AUTHOR=IROBERTS
MODULE_VERSION=0.04
inherit perl-module

DESCRIPTION="OpenSSL's multiprecision integer arithmetic"

SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="dev-libs/openssl"
DEPEND="${RDEPEND}"

SRC_TEST="do"
