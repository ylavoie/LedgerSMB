#!/usr/bin/perl

use Module::CPANfile;
use Test::More;
use File::Find::Rule::Perl;

use Test::Dependencies exclude =>
  [ qw/ LedgerSMB PageObject / ],
  style => 'light';


my $file = Module::CPANfile->load;
die "No cpanfile" if ! $file;

my @on_disk = ();
sub collect {
    return if $File::Find::name !~ m/\.(pm|pl)$/;

my @on_disk =
   File::Find::Rule::Perl->perl_file->in('lib', 'old/bin', 'old/lib', 'old/bin');

push @on_disk, 'tools/starman.psgi';

my @ignores = qw(App::LedgerSMB::Admin App::Prove Image::Size
               LaTeX::Driver PGObject::Util::DBAdmin
               Starman TeX::Encode::charmap
               Data::Dumper Data::Printer
               Plack::App::REST
               lib warnings); # Why those 2 suddenly
# Data::Dumper & Data::Printer are tracked by PerlCritic. Let's not report twice
# use parent qw(Plack::App::REST) fails

my $phases = 'runtime';

subtest 'runtime' => sub {
ok_dependencies($file, \@on_disk,
                phases => 'runtime',
                    features => [],
                    ignores => \@ignores );
};

for my $feature ( @{$file->features}) {
    subtest $feature => sub {
        ok_dependencies($file, \@on_disk,
                        phases => 'runtime',
                        features => $feature,
                        ignores => \@ignores );
    };
}

if ( $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development' ) {
    for my $phase (qw/configure build/) {
        subtest $phase => sub {
            ok_dependencies($file, \@on_disk,
                            phases => ['runtime',$phase],
                            ignores => \@ignores );
        };
    }
    subtest 'test' => sub {
        @on_disk = File::Find::Rule::Perl->perl_file->in('t');
        ok_dependencies($file, \@on_disk,
                        phases => 'test',
                        ignores => \@ignores );
    };
    subtest 'develop' => sub {
        @on_disk = File::Find::Rule::Perl->perl_file->in('xt');
        push @ignores, 'Pherkin::Extension::Weasel'; # Dynamicaly loaded
        push @ignores, 'Weasel';                     # Dynamicaly loaded
        push @ignores, 'Weasel::Driver::Selenium2';  # Dynamicaly loaded
        push @ignores, 'TAP::Parser::SourceHandler::pgTAP'; # Transparent load
        push @ignores, 'COATest';                    # We do provide it. Removed from cpanfile
        ok_dependencies($file, \@on_disk,
                        phases => 'develop',
                        ignores => \@ignores );
    };
}
