use v6;

module Test::META:ver<v0.0.1>:auth<github:jonathanstowe> {
   my $*META-FILE;

   use Test;
   use META6;


   sub meta-ok() is export(:DEFAULT) {
      subtest {

      }
   }
}

# vim: expandtab shiftwidth=4 ft=perl6
