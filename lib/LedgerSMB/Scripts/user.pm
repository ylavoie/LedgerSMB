=pod

=head1 NAME

LedgerSMB::Scripts::user - web entry points for user self-administration

=head1 SYNPOSIS

User preferences and password setting routines for LedgerSMB.  These are all
accessible to all users and do not perform administrative functions.

=head1 DIFFERENCES FROM ADMIN MODULE

Although there is some overlap between this module and that of the admin module,
particularly regarding the setting of passwords, there are subtle differences as
well.  Most notably an administrative password reset is valid by default for
only one day, while the duration of a user password change is fully configurable
and defaults to indefinite validity.

=head1 METHODS

=over

=cut
package LedgerSMB::Scripts::user;
use LedgerSMB::Template;
use LedgerSMB::DBObject::User;
use LedgerSMB::App_State;
use strict;
use warnings;

our $VERSION = 1.0;

my $slash = '::';

=item preference_screen

Displays the preferences screen.  No inputs needed.

=cut

use Data::Dumper;
$Data::Dumper::Indent = 2;
$Data::Dumper::Maxdepth = 2;
$Data::Dumper::Sortkeys = 1;
use Data::Printer caller_info => 1, colored => 1, separator => ', ',
        color => {
        array       => 'bright_white',  # array index numbers
        number      => 'bright_blue',   # numbers
        string      => 'bright_yellow', # strings
        class       => 'bright_green',  # class names
        method      => 'bright_green',  # method names
        undef       => 'bright_red',    # the 'undef' value
        hash        => 'magenta',       # hash keys
        regex       => 'yellow',        # regular expressions
        code        => 'green',         # code references
        glob        => 'bright_cyan',   # globs (usually file handles)
        vstring     => 'bright_blue',   # version strings (v5.16.0, etc)
        repeated    => 'white on_red',  # references to seen values
        caller_info => 'bright_cyan on_blue',   # details on what's being printed
        weak        => 'cyan',          # weak references
        tainted     => 'red',           # tainted content
        escaped     => 'bright_red',    # escaped characters (\t, \n, etc)

        # potential new Perl datatypes, unknown to Data::Printer
        unknown     => 'bright_yellow on_blue',
     };

sub preference_screen {
    my ($request, $user) = @_;
    warn np $user;
    if (! defined $user) {
        $user = LedgerSMB::DBObject::User->new({base => $request});
    warn np $user;
        $user->get($user->{_user}->{id});
    warn np $user;
    }
    $user->get_option_data;

    my $template = LedgerSMB::Template->new(
        user     => $user,
        locale   => $request->{_locale},
        path     => 'UI/users',
        template => 'preferences',
        format   => 'HTML'
    );

    my $creds = $request->{_auth}->get_credentials();
    $user->{login} = $creds->{login};
    $user->{password_expires} =~ s/:(\d|\.)*$//;
    return $template->render_to_psgi({ request => $request,
                                       user => $user });
}

=item save_preferences

Saves preferences from inputs on preferences screen and returns to the same
screen.

=cut

sub save_preferences {
    my ($request) = @_;
    $request->{_user}->{language} = $request->{language};
    my $locale =  LedgerSMB::Locale->get_handle($request->{_user}->{language});
    $request->{_locale} = $locale;
    $LedgerSMB::App_State::Locale = $locale;
    my $user = LedgerSMB::DBObject::User->new({base => $request});
    $user->{dateformat} =~ s/$slash/\//g;
    if ($user->{confirm_password}){
        $user->change_my_password;
    }
    warn np $user;
    $user = $user->save_preferences;
    return preference_screen($request, $user);
}

=item change_password

Changes the password, leaves other preferences in place, and returns to the
preferences screen

=cut

sub change_password {
    my ($request) = @_;
    warn np $request->{dbh};
    my $user = LedgerSMB::DBObject::User->new({base => $request});
    if ($user->{confirm_password}){
        $user->change_my_password;
    }
    return preference_screen($request, $user);
}

=back

=head1 COPYRIGHT

Copyright (C) 2009 LedgerSMB Core Team.  This file is licensed under the GNU
General Public License version 2, or at your option any later version.  Please
see the included License.txt for details.

=cut


1;
