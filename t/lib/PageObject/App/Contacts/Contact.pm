package PageObject::App::Contacts::Contact;

use strict;
use warnings;

use Carp;
use PageObject;

use Moose;
extends 'PageObject';

my $page_heading = 'Contact creation';

__PACKAGE__->self_register(
              'contacts',
              './/form[@id="contacts"]',
              tag_name => 'form',
              attributes => {
                  id => 'contacts',
              });

sub _verify {
    my ($self) = @_;

#    $self->find(".//*[\@class='listtop'
#                      and normalize-space(text())='$page_heading']");
    $self->find(".//*[normalize-space(text())='$page_heading']");

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
