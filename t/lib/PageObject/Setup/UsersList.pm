package PageObject::Setup::UsersList;

use strict;
use warnings;

use Carp;
use Moose;
use PageObject;
extends 'PageObject';

__PACKAGE__->self_register(
              'setup-userslist',
              './/body[@id="setup-list-users"]',
              tag_name => 'body',
              attributes => {
                  id => 'setup-list-users',
              });

sub _verify {
    my ($self) = @_;

    #@@@TODO: There's an assertion missing here
    $self->find_all('*contains', text => $_)
        for ("Available Users", "Username");

    return $self;
};

sub get_users_list {
    my ($self) = @_;

    my $user_links = $self->find('.//table[@id="user_list"]')
        ->find_all('.//a');

    my @users = map { $_->get_text } @{ $user_links };

    return \@users;
}

sub edit_user {
    my ($self, $user) = @_;

    return $self->session->page->click_and_wait_for_body(".//a[text()='$user']");
}


__PACKAGE__->meta->make_immutable;

1;
