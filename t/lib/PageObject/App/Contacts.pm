package PageObject::App::Contacts;

use strict;
use warnings;

use Carp;
use PageObject;

use PageObject::App::Contacts;
use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'contacts',
              './/form[@id="contacts"]',
              tag_name => 'form',
              attributes => {
                  id => 'contacts',
              });


sub _verify {
    my ($self) = @_;

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
