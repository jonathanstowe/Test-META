use v6.c;

=begin pod

=head1 NAME

Test::META - Test that a Perl 6 project has a good and proper META file

=head1 SYNOPSIS

This is the actual *t/030-my-meta.t* from this distribution

=begin code
#!perl6

use v6.c;

use Test;
use Test::META;

plan 1;

# That's it
meta-ok();


done-testing;
=end code

=head1 DESCRIPTION

This provides a simple mechanism for module authors to have some
confidence that they have a working distribution META description
file (as described in L<http://design.perl6.org/S22.html#META6.json>.)

It exports one subroutine *meta-ok* that runs a single sub-test that
checks that:

=item The META file (either META6.json or META.info) exists

=item The META file can be parsed as valid JSON

=item The attributes marked as "mandatory" are present

=item The files mention in the "provides" section are present.

=item The authors field is used instead of author

=item The name attribute doesn't have a hyphen rather than '::'

=item The version exists and it isn't '*'

=item If the META6 file specifies a meta-version version greater than 0 that the version strings do not contain a 'v' prefix

The C<meta-ok> takes one optional adverb C<:relaxed-name> that can stop
the name check being a fail if it is intended to be like that.

There are mechanisms (used internally for testing) to over-ride the
location or name of the META file and these can be seen in the test-suite,
though they won't typically be needed.

=end pod


module Test::META:ver<0.0.14>:auth<github:jonathanstowe> {

    use Test;
    use META6:ver(v0.0.4+);
    use Test::META::LicenseList;
    use URI;
    our $TESTING = False;

    sub my-diag(Str() $mess) {
        diag $mess unless $TESTING;
    }

    sub meta-ok(:$relaxed-name) is export(:DEFAULT) {
        subtest {

            my $meta-file = get-meta();

            if $meta-file.defined and $meta-file.e {
                pass "have a META file";
                my $meta;
                my Int $seen-vee = 0;
                lives-ok {
                    CONTROL {
                        when CX::Warn {
                            if $_.message ~~ /'prefix "v" seen in version string'/ {
                                $seen-vee++;
                                $_.resume;
                            }
                        }
                    };
                    $meta = META6.new(file => $meta-file);
                }, "META parses okay";
                if $meta.defined {
                    ok check-mandatory($meta), "have all required entries";
                    ok check-provides($meta), "'provides' looks sane";
                    ok check-authors($meta), "Optional 'authors' and not 'author'";
                    ok check-license($meta), "License is correct";
                    ok check-name($meta, :$relaxed-name), "name has a hyphen rather than '::' (if this is intentional please pass :relaxed-name to meta-ok)";
                    # this is transitional as the method changed in META6
                    ok ($meta.?meta6 | $meta.?meta-version ) ~~ Version.new(0) ?? True !! $seen-vee == 0, "no 'v' in version strings (meta-version greater than 0)";
                    ok check-version($meta), "version is present and doesn't have an asterisk";
                    ok check-sources($meta), "have usable source";
                }
            }
            else {
                flunk "don't have META file";
            }

        }, "Project META file is good";
    }

    our sub get-meta() {
        $*META-FILE // do {
            my $meta;
            for meta-candidates().map({ dist-dir.add($_) }) -> $m {
                if $m.e {
                    $meta = $m;
                    last;
                }
            }
            $meta;
        }
    }

    our sub check-mandatory(META6:D $meta --> Bool) {
        my Bool $rc = True;

        for $meta.^attributes -> $attr {
            if $attr.does(META6::MetaAttribute) {
                if $attr.optionality ~~ META6::Mandatory {
                    if not $attr.get_value($meta).defined {
                        my $name = $attr.name.substr(2);
                        $rc = False;
                        my-diag "required attribute '$name' is not defined";
                    }
                }
            }
        }
        $rc;
    }

    our sub check-provides(META6:D $meta --> Bool) {
        my Bool $rc = True;

        for $meta.provides.kv -> $name, $path {
            if not dist-dir().add($path).e {
                $rc = False;
                my-diag "file for '$name' '$path' does not exist";
            }
            elsif $path.IO.is-absolute {
                $rc = False;
                my-diag "file for '$name' '$path' is absolute, it should be relative to the dist directory";
            }
        }

        $rc;
    }

    our sub check-authors(META6:D $meta --> Bool) {
        my Bool $rc = True;

        if $meta.author.defined {
            if $meta.authors.elems == 0 {
                $rc = False;
                my-diag "there is an 'author' field rather than the specified 'authors'";
            }
        }

        $rc;
    }

    our sub check-license(META6:D $meta --> Bool) {
        my Bool $rc = True;
        if $meta.license.defined {
            my @license-list = get-license-list();
            if $meta.license ne any(@license-list) {
                if $meta.license eq any('NOASSERTION', 'NONE') {
                    my-diag "NOTICE! License is $meta.support.license(). This is valid, but licenses are prefered.";
                    $rc = True;
                }
                elsif $meta.support.license {
                    my-diag "notice license is “$meta.license()’, which isn't a SPDX standardized identifier, but license URL was supplied";
                    $rc = True;
                }
                else {
                    my-diag qq:to/END/;
                    license ‘$meta.license()’ is not one of the standardized SPDX license identifiers.
                    please use use one of the identifiers from https://spdx.org/licenses/
                    for the license field or if your license is not on the list,
                    include a URL to the license text as one of the 'support' keys
                    in addition to listing its name.
                    END
                    $rc = False;
                }
            }
        }
        $rc;
    }

    our sub check-name(META6:D $meta, :$relaxed-name --> Bool) {
        my Bool $rc = True;

        if $meta.name.defined {
            if not $relaxed-name {
                 my Str $name = $meta.name;
                 if so $name ~~ /\-/ && $name !~~ /\:\:/ {
                     $rc = False;
                 }
            }
            else {
                $rc = True;
            }
        }
        else {
            $rc = False;
        }

        $rc;
    }

    our sub check-version(META6:D $meta --> Bool ) {
        $meta.version.defined && not any($meta.version.parts) eq "*"
    }

    our sub check-sources(META6:D $meta --> Bool ) {
        my $src-count = 0;

        for ( $meta.source-url, $meta.support.source ).grep(*.defined) -> $source {
            if try URI.new($source) -> $uri {
                if $uri.host eq 'github.com' {
                    if $uri.path ~~ /\.git$/ {
                        $src-count++;
                    }
                    else {
                        my-diag "github source $source needs to end in .git";
                    }
                }
                else {
                    $src-count++;
                }
            }
            else {
                my-diag "source $source is not a valid URI";
            }
        }
        ?$src-count;
    }

    sub meta-candidates() {
        @*META-CANDIDATES // <META6.json META.info>;
    }

    sub dist-dir() {
        $*DIST-DIR // test-dir().parent;
    }

    sub test-dir() {
         $*TEST-DIR // $*PROGRAM.parent;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
