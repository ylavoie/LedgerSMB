package PageObject::Setup::Login;

use strict;
use warnings;

use Carp;
#use PageObject;

use PageObject::Setup::Admin;
use Selenium::Remote::WDKeys;

use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'setup-login',
              './/body[@id="setup-login"]',
              tag_name => 'body',
              attributes => {
                  id => 'setup-login',
              });

sub url { return '/setup.pl'; }

for my $func (qw(login _verify)) {
    before $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func++"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

for my $func (qw(login _verify)) {
    after $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func--"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

sub _verify {
    my ($self) = @_;

    $self->find('*labeled', text => $_)
        for ("Password", "Database", "Super-user login");
    return $self;
};


sub login {
    my ($self, %args) = @_;
    my $user = $args{user};
    my $password = $args{password};
    my $company = $args{company};
    my $next_page = $args{next_page} // '*setup-admin';

    do {
        my $element =
            $self->find('*labeled', text => $_->{label});
        $element->send_keys($_->{value});
        $element->send_keys(KEYS->{'tab'}) if defined $_->{list};
    } for ({ label => "Super-user login",
             value => $user,
             list => 1 },
           { label => "Password",
             value => $password },
           { label => "Database",
             value => $company });

    return $self->session->page->click_and_wait_for_body('*button', text => "Login");
}

sub login_non_existent {
    my $self = shift @_;

    return $self->login(@_,
                        # also setup-admin,
                        # but then CreateConfirm and Admin need merging
        next_page => "PageObject::Setup::CreateConfirm");
}


__PACKAGE__->meta->make_immutable;

1;
