# Test::META

Test that a Raku project has a good and proper META file.

[![CI](https://github.com/jonathanstowe/Test-META/actions/workflows/main.yml/badge.svg)](https://github.com/jonathanstowe/Test-META/actions/workflows/main.yml)

## Synopsis

This is the actual `t/030-my-meta.t` from this distribution

```Perl6
#!raku

use v6;
use lib 'lib';

use Test;
use Test::META;

plan 1;

# That's it
meta-ok();


done-testing;
```


However, you may want to make this test conditional, only run by the
author (e.g. by checking the `AUTHOR_TESTING` environment variable). Also,
regular users of your module will not need Test::META on their system):

```Perl6
use v6;
use lib 'lib';
use Test;
plan 1;

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if AUTHOR {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
     skip-rest "Skipping author test";
     exit;
}
```

If you are running under Travis CI you can set the right environment
variable in the YAML. One way to do this is like this:

```
script:
  - AUTHOR_TESTING=1 prove -v -e "raku -Ilib"
```

Other continuous integration systems will have a similar facility.

## Description

This provides a simple mechanism for module authors to have some
confidence that they have a working distribution META description
file (as described in [S22](http://design.raku.org/S22.html#META6.json)).

It exports one subroutine `meta-ok` that runs a single sub-test that
checks that:

   *  The META file (either META6.json or META.info) exists
   *  That the META file can be parsed as valid JSON
   *  That the attributes marked as "mandatory" are present
   *  That the files mentioned in the "provides" section are present.

There are mechanisms that are used internally for testing to override the
location or name of the META file. These can be seen in the test suite
though they are not typically needed.

## Installation

You can install directly with "zef":

```
# Remote installation
$ zef install Test::META

# From the source directory
$ zef install .
```

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/Test-META

If you can think of further tests that could be made, please send a
patch.  Bear in mind that the tests for the structure of the META file
and particularly the required fields rely on the implementation of the
module [META6](https://github.com/jonathanstowe/META6) and you may want
to consider changing that instead.

## Licence

This is free software.

Please see the [LICENCE](LICENCE) for the details.

© Jonathan Stowe 2015, 2016, 2017
