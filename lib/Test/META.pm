use v6;

module Test::META:ver<v0.0.1>:auth<github:jonathanstowe> {

    use Test;
    use META6;


    sub meta-ok() is export(:DEFAULT) {
        subtest {

            my $meta-file = get-meta();

            if $meta-file.defined and $meta-file.d {
                pass "have a META file";
                my $meta;
                lives-ok { $meta = META6.new(file => $meta-file) }, "META parses okay";
                if $meta.defined {
                    ok check-mandatory($meta), "have all required entries";
                    ok check-provides($meta), "'provides' looks sane";
                }
            }
            else {
                flunk "don't have META file";
            }

        }
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
                        diag "required attribute '$name' is not defined";
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
                diag "file for '$name' '$path' does not exist";
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
