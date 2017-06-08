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

use Time::HiRes qw(time);
use POSIX qw(strftime);

sub _get_time {
    my $t = time;
    my $date = strftime "%Y%m%d %H:%M:%S", localtime $t;
    $date .= sprintf ".%03d", ($t-int($t))*1000; # without rounding
    return $date;
}

sub _build_body {
    my ($self) = @_;

    return $self->find('body.done-parsing', scheme => 'css');
}

sub wait_for_body {
    my ($self) = @_;
    my $old_body = $self->body if $self->has_body;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            my $body = $self->find_element_by_css('body.done-parsing');
            $old_body = undef if not $body->_id;
            return !$old_body && $body->_id;
        });

    return $self->body;
}

1;
