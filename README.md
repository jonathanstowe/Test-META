# Test::META

Test that a Perl 6 project has a good and proper META file

## Synopsis

This is the actual *t/030-my-meta.t* from this distribution

```
#!perl6

use v6;
use lib 'lib';

use Test;
use Test::META;

plan 1;

# That's it
meta-ok();


done-testing;
```

## Description

This provides a simple mechanims for module authors to have some
confidence that they have a working distribution META description
file (as described in http://design.perl6.org/S22.html#META6.json .)

It exports one subroutine *meta-ok* that runs a single sub-test that
checks that:

   *  The META file (either META6.json or META.info) exists
   *  That the META file can be parsed as valid JSON
   *  That the attributes marked as "mandatory" are present
   *  That the files mention in the "provides" section are present.

There are mechanisms (used internally for testing,) to over-ride the
location or name of the META file and these can be seen in the test-suite,
though they won't typically be needed.


## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Test::META

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Test-META

If you can think of further tests that could be made, please send a
patch.  Bear in mind that the tests for the stucture of the META file
and particularly the required fields rely on the implementation of the
module [META6](https://github.com/jonathanstowe/META6) and you may want
to consider changing that instead.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
