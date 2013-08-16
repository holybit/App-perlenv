package App::perlenv;

# VERSION

# ABSTRACT: Create Perl environments.

use Mouse;

use Cwd qw(abs_path);
use Config;
use Getopt::Long;
use File::Path qw(mkpath);
use File::Basename;

use Config::Tiny;
use File::ShareDir;
use local::lib;

use Data::Printer;

sub new {
    my $class = shift;

    bless {
        argv           => [],
        config         => Config::Tiny->new,
        confif_file    => 0,
        perl           => $^X,
        perlbrew       => 0,
        self_contained => 0,
        share_dir      => undef,
        verbose        => 0
    }, $class;
}

sub parse_cli_opts {
    my $self = shift;

    #p @ARGV;
    p @_;
    Getopt::Long::Configure("bundling");
    Getopt::Long::GetOptions(
        'c|conf-file=s'    => $self->{conf_file}      = 1,
        'h|help'           => $self->usage(),
        'q|quiet'          => $self->{quiet}          = 1,
        's|self-contained' => $self->{self_contained} = 1,
        'v|verbose'        => $self->{verbose}        = 1,
        'V|version'        => $self->version()
    ) or usage();
}

sub version {
    my $self = shift;

    #my $version = $VERSION || 'unknown';
    #print "perlenv $version\n";
    exit;
}

sub usage {
    my $self = shift;

    print <<USAGE;
Usage: perlenv [OPTIONS] [PERLENV_ROOT] ...
Example: perlenv /MYPROJ/env

Options:
   -c, --conf-file         Use/Generate conf file
   -h, --help              Print help message
   -q, --quiet             Suppress output except for errors
   -s, --self-contained    Release management support
   -v, --verbose           Show extra output
   -V, --version           Show version

USAGE

    return 1;
}

sub perlenv_root_setup {
    my $self = shift;

    if ( $ENV{PERLENV_ROOT} ) {
        $self->{config}->{env}->{PERLENV_ROOT} = $ENV{PERLENV_ROOT};
    }
    elsif ( !$ARGV[0] ) {
        print "Must supply a PERLENV_ROOT\n";
        $self->usage();
    }
    elsif ( $ARGV[0] !~ /\// ) {
        $self->{conf}->{env}->{PERLENV_ROOT} = abs_path( $ARGV[0] );
    }

    # $ARGV[0] precedence over shell $PERLENV_ROOT
    if ( $ARGV[0] ) {
        $self->{conf}->{env}->{PERLENV_ROOT} = $ARGV[0];
    }

    $self->{conf}->{env}->{PERLENV_ROOT} =~ s/\/+$//;

    if ( !$self->{quiet} ) {
        print "PERLENV_ROOT=$self->{conf}->{env}->{PERLENV_ROOT}\n";
    }

    # TODO VERSION problem when doing dev work
    $self->{conf}->{env}->{PERLENV_VERSION} = '0.1';

    return 1;
}

#sub perlbrew_setup {
#my $self = shift;

#$conf->{env}->{PERLBREW_MANPATH} = $ENV{PERLBREW_MANPATH};
#$conf->{env}->{PERLBREW_PERL}    = $ENV{PERLBREW_PERL};
#$conf->{env}->{PERLBREW_VERSION} = $ENV{PERLBREW_VERSION};
#$conf->{env}->{PERLBREW_PATH}    = $ENV{PERLBREW_PATH};
#$conf->{env}->{PERLBREW_ROOT}    = $ENV{PERLBREW_ROOT};

#$conf->{env}->{PERLVERSION} = $ENV{PERLBREW_PERL};
#$conf->{env}->{PATH}        = $ENV{PERLBREW_PATH};

#$perlbrew = 1;

#return 1;
#}

#sub local_lib_setup {
#my $self = shift;

#my $local_lib_root =
#$conf->{env}->{PERLENV_ROOT} . "/perl5/$conf->{env}->{PERLVERSION}";

## TODO: Patch local::lib docs for DEACTIVATE/INTERPOLATE
#my %local_lib =
#local::lib->build_environment_vars_for( $local_lib_root, 0, 0 );

## fixup vars
#$conf->{env}->{PATH} .= ':' . $local_lib{PATH};
#delete $local_lib{PATH};
#$local_lib{PERL_LOCAL_LIB_ROOT} =~ s/\$PERL_LOCAL_LIB_ROOT://;
#$local_lib{PERL5LIB} =~ s/\:\$PERL5LIB//;

## merge %local_lib onto $conf->{env}
#while ( my ( $key, $value ) = each %local_lib ) {
#$conf->{env}->{$key} = $value;
#}

#return 1;
#}

## create PERLENV_ROOT and artifacts
#sub create_perlenv_root {
#my $self = shift;

#mkpath "$conf->{env}->{PERLENV_ROOT}/bin";
#if ( !$params{quiet} ) {
#print "bin dir created: $conf->{env}->{PERLENV_ROOT}/bin\n";
#}

#my $symlink_exists = eval {
#sub create_perlenv_root {
#my $conf = shift;

#mkpath "$conf->{env}->{PERLENV_ROOT}/bin";
#if ( !$params{quiet} ) {
#print "bin dir created: $conf->{env}->{PERLENV_ROOT}/bin\n";
#}

#my $symlink_exists = eval {
#symlink( $Config{perlpath}, "$conf->{env}->{PERLENV_ROOT}/bin/perl" );
#1;
#};
#if ( !$symlink_exists ) {
#print
#"ERROR: perl symlink creation failed: $conf->{env}->{PERLENV_ROOT}/bin/perl -> $Config{perlpath}\n";
#exit 1;
#}
#else {
#if ( !$params{quiet} ) {
#print
#"perl symlink created: $conf->{env}->{PERLENV_ROOT}/bin/perl -> $Config{perlpath}\n";
#}
#}

#mkpath "$conf->{env}->{PERL_LOCAL_LIB_ROOT}";

#return 1;
#}

#sub create_plenv_script {
#my $self = shift;

#my $file_plenv = "$conf->{env}->{PERLENV_ROOT}/bin/plenv";

#open( my $tmpl, "<", "$share_dir../share/plenv.tmpl" )
#or die "Cannot open < $share_dir../share/plenv.tmpl: $!";
#open( my $plenv, ">", $file_plenv ) or die "Cannot open > $file_plenv: $!";
#while (<$tmpl>) {
#if (/\{PLENV\}/) {
#foreach my $key ( sort keys $conf->{env} ) {
#print $plenv "export $key=\"$conf->{env}->{$key}\"\n";
#}
#}
#else {
#print $plenv $_;
#}
#}
#close($tmpl);
#close($plenv);

#chmod 0755, $file_plenv;

#if ( !$params{quiet} ) {
#print "plenv script created: $conf->{env}->{PERLENV_ROOT}/bin/plenv\n";
#}

#return 1;
#}

sub share_dir {
    my $self = shift;

    eval { $self->{share_dir} = File::ShareDir::dist_dir('App-perlenv'); };
    if ($@) {
        $self->{share_dir} = ( fileparse( abs_path($0) ) )[1];
    }
}

## $conf is the default data structure for all exposed vars (e.g., [env])
## regardless if there is a perlenv.ini conf file or not
#my $conf = Config::Tiny->new;
#if ( $conf_file && !-e $conf_file ) {
#print "No such configuration file: $conf_file\n";
#exit 1;
#}

#perlenv_root_setup($conf);

## w/ perlbrew
#if ( exists $ENV{PERLBREW_PATH} && exists $ENV{PERLBREW_PERL} ) {
#perlbrew_setup($conf);
#}

## w/out perlbrew
#else {
#$conf->{env}->{PATH}        = $Config{bin};
#$conf->{env}->{PERLVERSION} = $Config{version};
#}

#local_lib_setup($conf);
#create_perlenv_root($conf);
#delete $conf->{env}->{PERLVERSION};
#create_plenv_script($conf);

1;

__END__

=head1 NAME

perlenv - Create independent Perl environments

=head1 WARNING

B<This software is under development and considered alpha quality until version
v1.0. Things might be broke and/or less then ideal. If you have ideas about
making App::perlenv better please open an issue on github or contact the author,
holybit, on perl IRC toolchain channel. All development for this module is
conducted on github.>

=head1 NOTICE

If you think the design is helter skelter now is the time to speak up. Currently
design is minimal to encourage input and refinement. All development for this
module is conducted on github.

=head1 SYNOPSIS

    # Setup an app/project to run under perlenv
    #
    $ cd MYPROJ
    $ perlenv perlenv

    # source activate to set your shells Perl environment
    $ cd perlenv
    $ source bin/activate

    # MYPROJ/perlenv/perl symlinks to first Perl on env C<PATH>

    # all modules installed to MYPROJ/env/perl5/PERLVERSION/
    # later you can revert your shell environment with shell function
    $ deactivate

    # Setup an app/project to run under perlenv
    # using shell variable
    #
    $ export PERLENV_ROOT=/tmp/myproj/env
    $ perlenv
    $ . $PERLENV_ROOT/bin/plenv

    # perlbrew detection is automatic assuming the shell
    # environment is already setup
    #
    $ perlbrew use perl-5.16.2
    $ cd MYPROJ
    $ perlenv ENV
    $ source ENV/activate

    # setup to use Perl other then your PATH default
    #
    $ export PERLPATH=/opt/perl/5.14.2/
    $ cd MYPROJ
    $ /opt/perl/5.14.2/bin/perl perlenv env

    # self contained C<perlenv>
    #
    $ perlenv -s /home/foo/git/baz
    # C<PERLENV_ROOT> = /home/foo/git/baz/env
    # copies perlenv to C<PERLENV_ROOT>
    # C<PERLENV_ROOT>/perlenv.ini created
    # release management tools setup env via C<PERLENV_ROOT>/perlenv
    # on each target machine and exclude MYPROJ/env/plenv from VCS

=head1 DESCRIPTION

C<perlenv> is a tool to create independent Perl environments. There are a number
of common environment dilemmas most projects with Perl code face.

=over

=item *

Which installed version of Perl to use.

=item *

Library installation, use and consistency.

=item *

Environment consistency as source code migrates from dev to ci, tst and prd.

=back

C<perlenv> extends the local::lib tool to create a consistent structure and
mechanism for creating consitent repeatable Perl shell environments. It features
built in perlbrew support, extendible Perl shell environment tweaking, ini file
configuration, self contained option for release management support and has zero
prerequisite modules.

=head1 INSTALLATION

Install C<perlenv> to the system Perl.

    cpanm App::Perlenv

Optionally, you can tweak your shell Perl environement variables with
L<local::lib|local::lib> and install C<perlenv> to a custom location.

    eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"
    cpanm App::Perlenv

=head1 USING PERLENV

C<perlenv> works on a project basis, where a project is a directory typically
under the control of a VCS (e.g. Git, SVN, CVS, etc.). Some folks think of their
project as an application of sorts.

C<perlenv> creates a C<PERLENV_ROOT> directory inside your project wherever you
specifiy.

    # create C<PERLENV_ROOT> env/ in CWD, CWD/env is referred to as C<PERLENV_ROOT>
    $ perlenv env
    # or
    $ perlenv .

    # or name C<PERLENV_ROOT> whatever you like
    $ perlenv app

C<PERLENV_ROOT>/ contains a number of standard files and directories.

    $ ls -1 C<PERLENV_ROOT>/env
    perl -> $PERLPATH   # symlink
    plenv               # shell script to be sourced for all env vars
    perl5/$PERLVERSION  # lib home and target for lib installs

To set your shell environment up source the C<PERLENV_ROOT>/env/plenv.

    $ cd C<PERLENV_ROOT>
    $ . ./perlenv
    $ printenv | grep PERL

You can revert your environment easily with a shell function exported by
C<plenv>.

    $ plenv-off

=head1 ENVIRONMENT VARIABLES

C<perlenv> sniffs your environement for various shell variables before building
the C<plenv> shell script.

The version of Perl to use by default is the one that invoked C<perlenv>. For
example if the first Perl on your shell C<PATH> is /usr/bin/perl and you type

    $ perlenv .

Sourcing C<plenv> will set /usr/bin/perl as the default Perl. If you want to use
a differnt Perl than what C<perlenv> is invoked with then set the shell
C<PERLPATH> variable.

    $ export PERLPATH=/opt/perl/5.14.2/bin/perl

C<perlbrew> detection is built in assuming that you have already setup shell
variables with C<perlbrew> prior to invoking C<perlenv> or that a
C<PERLENV_ROOT>/init file produced by C<perlbrew> exists. Using the C<perlbrew>
init solution is noramally only used for the self contained option.

    $ perlbrew switch perl-5.14.2
    $ perlenv -s

=head1 CONFIGURATION

C<perlenv> makes use of an INI style config file where appropriate.

=head1 RELEASE MANAGEMENT

Release management is the discipline of managing software releases. For example,
imagine your developing an application, MYPROJ, on your local DEV machine. Your
using C<perlenv> to manage MYPROJ's Perl environment. Eventually, you want to
release MYPROJ to target machine(s) (TST, CI, PROD, etc.).

=begin text

 ---------        ---------
|   DEV   |  ->  |   TST   |
|  5.14.2 |      |  5.14.2 |
 ---------        ---------

     |
     V

 ---------
|   PRD   |
|  5.14.2 |
 ---------

=end text

Your using C<perlenv> to manage MYPROJ's Perl environment. In an ideal world
your DEV environment and the target systems are identical. The low bar is
all target environments must have the same Perl version down to the revision
number. Anything less is playing with fire. If they are identical or nearly
(i.e., other then Perl version) you can put MYPROJ's C<PERLENV_ROOT> under VCS
control and deliver it with the rest of your code base. Then your application
can source C<plenv> identical to how things work on DEV.

However, sometimes your DEV environment and your targets are sufficently
different. For example, what if DEV is a Linux OS, but the target machines are
SunOS? Or the DEV and target machines are the same OS but the former is 64 bit
architecture and the later 32 bit? To circumvent environment differences use
the C<perlenv> -s self contained option. This will copy C<perlenv> to
C<PERLENV_ROOT> along with the ini config file C<PERLENV_ROOT>/perlenv.ini

=head1 COMMAND-LINE OPTIONS

blah

=head1 SEE ALSO

L<local::lib|local::lib>, L<App::Perlbrew|App::Perlbrew> and L<virtualenv|virtualenv>

=head1 KNOWN BUGS

=over

=item *

Does not work on Windows. Patches welcome.

=back

Please, file all bugs on <github|https://github.com/holybit/App-perlenv/issues>.

=head1 ACKNOWLEDGMENTS

Thanks to Ricardo Signes, Chritopher J. Madsen, Jeff Thalhammer and others for
answering my endless toolchain questions which eventually spawned the birth of
C<perlenv>.

=head1 SPONSORS

Saint Micheal the Archangel, Saint Joseph of the Holy Family and Saint John
Vianney Curé d'Ars.

=cut

1;
