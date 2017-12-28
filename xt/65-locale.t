#!perl

use strict;
use warnings;
use utf8::all;

use File::Find;
use Test::More;
use YAML::Syck;

use LedgerSMB::App_State;
use Selenium::Remote::Driver;

use Data::Printer;

my @on_disk = ();

sub collect {
    my $module = $File::Find::name;
    return if $module !~ m~locale/po/([^\.]+)\.po$~;

    push @on_disk, $1
}
find(\&collect, $ARGV[0] // 'locale/po/');

plan tests => scalar @on_disk;

# Read config and setup test
my $config_data_whole = LoadFile('t/.pherkin.yaml');
my $selenium = $config_data_whole->{default}->{extensions}->{'Pherkin::Extension::Weasel'}->{sessions}->{selenium};

my $browser = $selenium->{driver}->{caps}->{browser_name} =~ /\$\{([^\}]+)\}/
          ? $ENV{$1} // 'phantomjs'
          : $selenium->{driver}->{caps}->{browser_name};

my $remote_server_addr = $selenium->{driver}->{caps}->{remote_server_addr} =~ /\$\{([a-zA-Z0-9_]+)\}/
          ? $ENV{$1} // 'localhost'
          : $selenium->{driver}->{caps}->{remote_server_addr};

my $base_url = $selenium->{base_url} =~ /\$\{([a-zA-Z0-9_]+)\}/
          ? $ENV{$1} // 'http://localhost:5000'
          : $selenium->{base_url};

# Do test
sub content_test {
    my ($locale) = @_;

    my $profile;
    my $handle = LedgerSMB::Locale->get_handle($locale);
    LedgerSMB::App_State::set_Locale($handle);

#    $browser = 'firefox';
    my %caps = (
              port => $selenium->{driver}->{caps}->{port},
              browser_name => $browser,
              remote_server_addr => $remote_server_addr,
    );
    # Browser specific language settings
    if ( $browser eq 'phantomjs' ) {
        $caps{'extra_capabilities'} = {
                                           'phantomjs.page.customHeaders.Accept-Language' => $locale
                                      };
    } elsif ( $browser eq 'chrome' ) {
        $caps{'extra_capabilities'} = {
                                           'chromeOptions' => {
                                               'args' => [
                                                   "lang=$locale"
                                               ]
                                           }
                                      };
    } elsif ( $browser eq 'firefox' ) {
        require Selenium::Firefox::Profile;
        my $profile = Selenium::Firefox::Profile->new;
        $profile->set_preference(
            'intl.accept_languages' => $locale,
        );
        $caps{'firefox_profile'} = $profile;
    }

    my $driver = new Selenium::Remote::Driver(%caps)
              || die 'Unable to connect to remote browser';

    $driver->set_implicit_wait_timeout(30000); # 30s
    $driver->get($base_url . '/login.pl');

    subtest $locale => sub {

        my $element = $driver->find_element('//label[@for="password"]');
        ok($element, 'got a password');

        my $label = $element->get_text;
        my $t = LedgerSMB::App_State->Locale->text('Password');

        TODO: {
            local $TODO = "$label not yet translated in $locale"
                if $label ne $t;
            ok($label eq $t,"got translated password: '$label'->'$t'");
        }
    }
}

content_test($_) for sort @on_disk;
done_testing;
