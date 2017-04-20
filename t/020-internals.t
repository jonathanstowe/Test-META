#!perl6

use v6.c;

use Test;

use META6;
use Test::META;

diag "the following may make some diagnostics from the module itself";

$Test::META::TESTING = True;

lives-ok { Test::META::get-meta() }, "get-meta";

{
    # non-existent but specified implicitly;
    my $*META-FILE = "flurblsleb";
    is Test::META::get-meta(), $*META-FILE, 'gen-meta respects $*META-FILE';
}
{
    my @*META-CANDIDATES = <flurblsleb wiobeke>/
    ok !Test::META::get-meta().defined, 'get-meta() uses @*META-CANDIDATES';

}
{
    my $*DIST-DIR = $*PROGRAM.parent.child('data');
    my @*META-CANDIDATES = <META.info.meta6>;

    ok my $meta = Test::META::get-meta(), "get-meta() with existing file";
    ok $meta.e, "file returned exists";
    is $meta.basename, 'META.info.meta6', "and the file we expected";

}

{
    nok Test::META::check-mandatory(META6.new()), "check-mandatory on empty META";
    my $good = META6.new(perl-version => Version.new("6"), version => Version.new("0.0.1"), description => "Test thing", name => "Test::META");

    ok Test::META::check-mandatory($good), "check-mandatory with all defined";
}

{
    ok Test::META::check-provides(META6.new()), "check-provides on empty META";
    nok Test::META::check-provides(META6.new(provides => ( 'HH::GG' => 'lib/Boodle',))), "check-provides with bogus provides";
    nok Test::META::check-provides(META6.new(provides => ('Test::META' => '/lib/Test/META.pm',))), "check-provides with my own files but absolute path";
    ok Test::META::check-provides(META6.new(provides => ('Test::META' => 'lib/Test/META.pm',))), "check-provides with my own files";
    ok Test::META::check-authors(META6.new()), "check-authors no authors";
    ok Test::META::check-authors(META6.new(authors => ["A.U. Thor"])), "check-authors with 'authors'";
    ok Test::META::check-authors(META6.new(authors => ["A.U. Thor"], author => "A.U. Thor")), "check-authors with 'authors' and 'author'";
    nok Test::META::check-authors(META6.new(author => "A.U. Thor")), "check-authors with 'author' only";
    ok Test::META::check-name(META6.new(name => "Test::META")), "check-name with good name";
    nok Test::META::check-name(META6.new(name => "Test-META")), "check-name with bad name";
    ok Test::META::check-name(META6.new(name => "Test-META"), :relaxed-name), "check-name with bad name but :relaxed-name";
    nok Test::META::check-license(META6.new(license => "Artistic")), "check-license with bad license name";
    ok Test::META::check-license(META6.new(
        license => "My Super Cool License", support => META6::Support.new(:license('https://mycoollicense.com/license'))
        )

    ), "check-license with bad license name";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
