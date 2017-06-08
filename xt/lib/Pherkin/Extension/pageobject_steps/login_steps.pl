#!perl


use strict;
use warnings;

use PageObject::App::Login;

use Test::More;
use Test::BDD::Cucumber::StepFile;

use Carp qw(croak);

Given qr/a logged in admin/, sub {
    PageObject::App::Login->open(S->{ext_wsl});
    S->{ext_wsl}->page->session->driver->user_error_handler(
        sub { return sub() {
            my ($self,$error) = @_;
            warn "UEH0 " . p $error;
            if ( $error && $error =~ /A modal dialog was open/ ) {
                my $pwd = $self->get_alert_text();
                if ( $pwd && $pwd =~ "Warning:  Your password will expire in" ) {
                    $self->accept_alert;
                    return undef;
                }
            } else {
                croak "UEH1 " . $error;
            }
            return $error;
        }}
    );
    S->{ext_wsl}->page->body->login(
        user => S->{"the admin"},
        password => S->{"the admin password"},
        company => S->{"the company"});
};



1;
