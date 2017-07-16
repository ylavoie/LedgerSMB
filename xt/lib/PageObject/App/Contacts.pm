package PageObject::App::Contacts;

use strict;
use warnings;

use PageObject;


use Moose;
extends 'PageObject';


__PACKAGE__->self_register(
              'add-contact',
              './/form[@id="add-contact"]',
              tag_name => 'form',
              attributes => {
                  id => 'add-contact',
              });


sub _verify {
    my ($self) = @_;

    return $self;
};

__PACKAGE__->meta->make_immutable;

1;
