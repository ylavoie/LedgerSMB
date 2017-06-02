package PageObject::Root;

use strict;
use warnings;

use Moose;
extends 'Weasel::Element::Document';

use Try::Tiny;

has body => (is => 'rw',
             isa => 'PageObject',
             required => 0,
             clearer => 'clear_body',
             predicate => 'has_body',
             builder => '_build_body',
             lazy => 1);

sub _build_body {
    my ($self) = @_;

    return $self->find_element_by_css('body.done-parsing');
}

sub wait_for_body {
    my ($self) = @_;
    my $old_body = $self->body if $self->has_body;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            if ($self->has_body) {
                return $self->_id
                    && $old_body->_id ? $self->_id->id ne $old_body->_id->id : 0;
            }
            else {
                return $self->find('body.done-parsing', scheme => 'css') ? 1 : 0;
            }
        });
    return $self->body;
}

1;
