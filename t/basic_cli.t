#!/usr/bin/env perl

use strict;
use warnings;
use File::Path qw/ remove_tree /;
use File::Temp qw/ tempdir /;
use FindBin;
use Test::More;

my $perlenv = $FindBin::Bin . '/../bin/perlenv';

if ( exists $ENV{PERLENV_ROOT} ) {
    delete $ENV{PERLENV_ROOT};
}

ok( qx/$perlenv -h/ =~ /^Usage:/, "help msg" );
ok( system("$perlenv > /dev/null 2>&1") >> 8 == 1,
    "unset \$PERLENV_ROOT exit status" );
ok( qx/$perlenv/ =~ /^Must supply a PERLENV_ROOT/, "unset \$PERLENV_ROOT msg" );
ok( qx/$perlenv -q/ =~ /^Must supply a PERLENV_ROOT/,
    "unset \$PERLENV_ROOT msg w/ quiet option"
);

my $tempdir_1 =
    tempdir( 'perlenv-test-XXXXXXXXXXXX', DIR => '/tmp', CLEANUP => 1 );
$ENV{PERLENV_ROOT} = $tempdir_1;
ok( system("$perlenv > /dev/null 2>&1") >> 8 == 0,
    "create \$PERLENV_ROOT via shell env"
);
ok( -d "$tempdir_1/bin",       "$tempdir_1/bin dir created" );
ok( -l "$tempdir_1/bin/perl",  "$tempdir_1/bin/perl symlink created" );
ok( -e "$tempdir_1/bin/plenv", "$tempdir_1/bin/plenv script created" );
ok( -x "$tempdir_1/bin/plenv", "$tempdir_1/bin/plenv script executable" );

my $tempdir_2 =
    tempdir( 'perlenv-test-XXXXXXXXXXXX', DIR => '/tmp', CLEANUP => 1 );
ok( system("$perlenv $tempdir_2 > /dev/null 2>&1") >> 8 == 0,
    "create PERLENV_ROOT via cli arg" );
ok( -d "$tempdir_2/bin",       "$tempdir_2/bin dir created" );
ok( -l "$tempdir_2/bin/perl",  "$tempdir_2/bin/perl symlink created" );
ok( -e "$tempdir_2/bin/plenv", "$tempdir_2/bin/plenv script created" );
ok( -x "$tempdir_2/bin/plenv", "$tempdir_2/bin/plenv script executable" );
remove_tree($tempdir_2);

# cli arg for PERLENV_ROOT takes precedence over shell env
ok( system("$perlenv $tempdir_2 > /dev/null 2>&1") >> 8 == 0,
    "create PERLENV_ROOT via cli arg w/ shell env set"
);
ok( -d "$tempdir_2/bin", "$tempdir_2/bin dir created" );

ok( qx/$perlenv -q $tempdir_2/ eq undef, "quiet option" );

done_testing();
