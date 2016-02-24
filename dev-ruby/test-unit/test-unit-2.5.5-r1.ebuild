# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_RUBY="ruby19 ruby20 jruby"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="TODO README.textile"

inherit ruby-fakegem

# Assume for now that ruby20 is not eselected yet and only depend on
# yard for the other ruby implementations. Without this assumption
# bootstrapping ruby20 won't be possible due to the yard dependency
# tree.
USE_RUBY="${USE_RUBY/ruby20/}" ruby_add_bdepend "doc? ( dev-ruby/yard )"
# redcloth is also needed to build documentation, but not available for
# jruby. Since we build documentation with the main ruby implementation
# only we skip the dependency for jruby in this roundabout way, assuming
# that jruby won't be the main ruby.
USE_RUBY="${USE_RUBY/ruby20 jruby/}" ruby_add_bdepend "doc? ( dev-ruby/redcloth )"

DESCRIPTION="An improved version of the Test::Unit framework from Ruby 1.8"
HOMEPAGE="http://test-unit.rubyforge.org/"

LICENSE="Ruby"
SLOT="2"
KEYWORDS="amd64 x86"
IUSE="doc test"

each_ruby_prepare() {
	case ${RUBY} in
		*jruby)
			# Avoid tests with slightly different output for jruby
			sed -i -e '/test_assert_nothing_thrown/,/^      end/ s:^:#:' \
				-e '/test_assert_throw/,/^      end/ s:^:#:' test/test-assertions.rb || die
			# And fix missing testunit exposed by it
			sed -i -e "9irequire 'testunit-test-util'" test/test-assertions.rb || die
			;;
	esac
}

all_ruby_compile() {
	all_fakegem_compile

	if use doc; then
		yard doc --title ${PN} || die
	fi
}

each_ruby_test() {
	# the rake audit using dev-ruby/zentest currently fails, and we
	# just need to call the testsuite directly.
	# rake audit || die "rake audit failed"
	local rubyflags

	[[ ${RUBY} == */jruby ]] && rubyflags="-X+O"

	${RUBY} ${rubyflags} test/run-test.rb || die "testsuite failed"
}

all_ruby_install() {
	all_fakegem_install

	newbin "${FILESDIR}"/testrb testrb-2
}
