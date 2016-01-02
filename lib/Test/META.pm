use v6;

=begin pod

=head1 NAME

Test::META - Test that a Perl 6 project has a good and proper META file

=head1 SYNOPSIS

This is the actual *t/030-my-meta.t* from this distribution

=begin code
#!perl6

use v6;

use Test;
use Test::META;

plan 1;

# That's it
meta-ok();


done-testing;
=end code

=head1 DESCRIPTION

This provides a simple mechanims for module authors to have some
confidence that they have a working distribution META description
file (as described in L<http://design.perl6.org/S22.html#META6.json>.)

It exports one subroutine *meta-ok* that runs a single sub-test that
checks that:

=item The META file (either META6.json or META.info) exists

=item That the META file can be parsed as valid JSON

=item That the attributes marked as "mandatory" are present

=item That the files mention in the "provides" section are present.

There are mechanisms (used internally for testing,) to over-ride the
location or name of the META file and these can be seen in the test-suite,
though they won't typically be needed.

=end pod


module Test::META:ver<v0.0.1>:auth<github:jonathanstowe> {

    use Test;
    use META6;

    our $TESTING = False;

    sub meta-ok() is export(:DEFAULT) {
        subtest {

            my $meta-file = get-meta();

            if $meta-file.defined and $meta-file.e {
                pass "have a META file";
                my $meta;
                lives-ok { $meta = META6.new(file => $meta-file) }, "META parses okay";
                if $meta.defined {
                    ok check-mandatory($meta), "have all required entries";
                    ok check-provides($meta), "'provides' looks sane";
                    ok check-authors($meta), "Optional 'authors' and not 'author'";
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
            for meta-candidates().map({ dist-dir.child($_) }) -> $m {
                if $m.e {
                    $meta = $m;
                    last;
                }
            }
            $meta;
        }
    }

    our sub check-mandatory(META6:D $meta) returns Bool {
        my Bool $rc = True;

        for $meta.^attributes -> $attr {
            if $attr.does(META6::MetaAttribute) {
                if $attr.optionality ~~ META6::Mandatory {
                    if not $attr.get_value($meta).defined {
                        my $name = $attr.name.substr(2);
                        $rc = False;
                        diag "required attribute '$name' is not defined" unless $TESTING;
                    }
                }
            }
        }
        $rc;
    }

    our sub check-provides(META6:D $meta) returns Bool {
        my Bool $rc = True;

        for $meta.provides.kv -> $name, $path {
            if not dist-dir().child($path).e {
                $rc = False;
                diag "file for '$name' '$path' does not exist" unless $TESTING;
            }
            elsif $path.IO.is-absolute {
                $rc = False;
                diag "file for '$name' '$path' is absolute, it should be relative to the dist directory" unless $TESTING;
            }
        }

        $rc;
    }

    our sub check-authors(META6:D $meta) returns Bool {
        my Bool $rc = True;

        if $meta.author.defined {
            if $meta.authors.elems == 0 {
                $rc = False;
                diag "there is an 'author' field rather than the specified 'authors'" unless $TESTING;
            }
        }

        $rc;
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
