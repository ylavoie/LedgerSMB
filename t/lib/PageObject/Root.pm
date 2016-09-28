package PageObject::Root;

use strict;
use warnings;
use Carp;

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

before clear_body => sub {
    my ($self) = @_;
    local @_;
    warn "clear_body++";
    for (my $i = 0 ; $i < 20 ; $i++ ) {
        my ($package, $filename, $line, $subroutine) = caller($i);
        print STDERR $package . '::' . $subroutine . '#' . $line . "\n" if $package ne 'Class::MOP::Method';
    }
    my $ref;
    $ref = $self->body if $self->has_body;
    while ($ref) {
        my $gone = 1;
        try {
            $ref->tag_name;
            # When successfully accessing the tag
            #  it's not out of scope yet...
            $gone = 0;
        };
        warn "tag_name " . ($gone ? "gone" : "still there");
        $ref = undef if $gone;
    }
};

after clear_body => sub {
    warn "clear_body--";
};

before wait_for_body => sub {
    warn "wait_for_body++";
};

after wait_for_body => sub {
    warn "wait_for_body--";
};

sub wait_for_body {
    my ($self) = @_;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            my $elem = $self->find('body.done-parsing', scheme => 'css');
            warn "body.done-parsing" . ( defined $elem ? " defined" : "" ) . ($elem && $elem->is_displayed ? " displayed" : "" );
            return ($elem && $elem->is_displayed) ? 1 : 0;
        });
    return $self->body;
}

1;
