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
