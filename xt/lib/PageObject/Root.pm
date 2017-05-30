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

    return $self->find('body.done-parsing', scheme => 'css');
}

sub wait_for_body {
    my ($self) = @_;
    my $old_id;
    $old_id = $self->body->_id->id if $self->has_body;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            if (defined $old_id) {
                my $tag = "body";
                my $current_id = $self->session->find_element_by_tag_name($tag);
                return $current_id == 0
                    || defined($current_id->id) && $current_id->id != $old_id;
            }
            else {
                return $self->find('body.done-parsing', scheme => 'css') ? 1 : 0;
            }
        });
    return $self->body;
}

1;
