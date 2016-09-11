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

sub select_class {
    my ($self, $class) = @_;

    $self->verify;
    my $elem = $self->find(".//*[\@id='person-entity-class']");

    $elem->clear;
    $elem->send_keys($class);

    $self->find("*button", text => "Generate Control Code")->click;
}


__PACKAGE__->meta->make_immutable;

1;
