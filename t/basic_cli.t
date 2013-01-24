#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use Test::More;

my $perlenv = $FindBin::Bin . '/../bin/perlenv';

#my @args = ($perlenv, ">", "/dev/null", "2>&1");
#ok(system($perlenv), 1);
my $rt = system("$perlenv > /dev/null 2>&1");
print $rt, "\n";
ok(system("$perlenv > /dev/null 2>&1") == 1, "cli PERLENV_ROOT not set");

done_testing();
