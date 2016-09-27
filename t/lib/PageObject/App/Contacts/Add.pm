package PageObject::App::Contacts::Add;

use strict;
use warnings;

use Carp;
use PageObject::App::Contacts;

use Moose;
extends 'PageObject::App::Contacts';

__PACKAGE__->self_register(
              'add-contact',
              './/form[@id="add-contact"]',
              tag_name => 'form',
              attributes => {
                  id => 'add-contact',
              });


my $page_heading = 'Add';

sub _verify {
    my ($self) = @_;

    $self->find(".//*[\@class='listtop'
                      and text()='$page_heading']");

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
