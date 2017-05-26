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

#use Data::Printer;
#use DateTime;
sub wait_for_body {
    my ($self) = @_;
    my $old_id = $self->session->find_element_by_tag_name("body")
        if $self->has_body;
#    my $dt = DateTime->now;
#    warn $dt->ymd . ' ' . $dt->hms . '.' . $dt->millisecond . ' ' . p $old_id;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            if (defined $old_id) {
                my $new_id = $self->session->find_element_by_tag_name("body");
#                my $dt = DateTime->now;
#                warn $dt->ymd . ' ' . $dt->hms . '.' . $dt->millisecond . ' ' . p $new_id;
                return $new_id eq "0"
                    || defined($new_id->id) && $new_id->id ne $old_id->id;
            }
            else {
#                my $dt = DateTime->now;
#                warn $dt->ymd . ' ' . $dt->hms . '.' . $dt->millisecond . ' ' . "Find";
                return $self->find('body.done-parsing', scheme => 'css') ? 1 : 0;
            }
        });
    return $self->body;
}

1;
