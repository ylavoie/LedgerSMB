#!/usr/bin/perl

use Selenium::Remote::Driver;
use Getopt::Long;

use Test::More tests=>1;

my $browser = 'remote';
my $server = '127.0.0.1';
my $url = 'http://www.google.com';

GetOptions ("browser=s" => \$browser,
            "server=s"  => \$server,
            "url=s"     => \$url)
or die("Error in command line arguments\n")
|| die("Invalid browser $browser")
     if !grep(/$browser/,qw(chrome firefox opera phantomjs random));

my %caps = (
          port => 4422,
          browser_name => $browser,
          remote_server_addr => $server,
          wd_context_prefix => $browser eq 'firefox' ? '' : '/wd/hub',
          #platform => 'LINUX',
          accept_ssl_certs => 1,
          version => 'ANY'
);
if ( $caps{browser_name} eq 'chrome' ) {
    $caps{'extra_capabilities'} = {
       'goog:chromeOptions' => {
           'args' => [
               #'lang=fr-CA',
               'no-sandbox',
               'headless',
               'verbose'
           ]
       }
    };
    $Selenium::Remote::Driver::FORCE_WD2 = 1;
} elsif ( $caps{browser_name} eq 'firefox' ) {
    require Selenium::Firefox::Profile;
    my $profile = Selenium::Firefox::Profile->new;
    $profile->set_preference(
        'intl.accept_languages' => 'fr-CA',
    );
    $self->{caps}{'firefox_profile'} = $profile;
    $caps{'extra_capabilities'} = {
        'moz:firefoxOptions' => {
            args    => [ '-headless' ],
            log     => { level => "trace"}
        }
    };
    no warnings 'once';
    $Selenium::Remote::Driver::FORCE_WD2=1;
} elsif ( $caps{browser_name} eq 'opera' ) {
    $caps{'extra_capabilities'} = {
       'operaOptions' => {
           'args' => [
               #'lang=fr-CA',
               'no-sandbox',
               'headless',
               'verbose'
           ]
       }
    };
    #$Selenium::Remote::Driver::FORCE_WD2 = 1;
} elsif ( $caps{browser_name} eq 'phantomjs' ) {
    $caps{'extra_capabilities'} = {
        "phantomjs.page.customHeaders.Accept-Language" => "fr-CA"
    };
}
#See http://search.cpan.org/~teodesian/Selenium-Remote-Driver-1.23/lib/Selenium/Remote/Driver.pm
#Connect to an already running selenium server
my $driver = Selenium::Remote::Driver->new(%caps)
          || die "Unable to connect to remote browser";

$driver->get($url);

if ($#ARGV < 1) {
    $driver->find_element('q','name')->send_keys("Hello WebDriver!");
    ok($driver->get_title =~ /Google/,"$browser: title matches google");
} elsif ( $ARGV[1] =~ /tmp/ ) {
    my $e = $driver->find_element('target','id');
    $e->click;
    my $t = $e->get_text;
    ok($t =~ /Foo/,"$browser: $t matches Foo");
} else {
    my $title = $driver->get_title;
    ok( $title =~ /LedgerSMB 1\.[67]\.[0-9]+(0-dev)?/,"$browser: Title match LedgerSMB");
}
