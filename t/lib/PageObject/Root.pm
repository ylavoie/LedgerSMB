package PageObject::Root;

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
    my $ref;
    $ref = $self->body if $self->has_body;
    $self->clear_body;

    $self->session->wait_for(
        sub {
            if ($ref) {
                my $gone = 1;
                try {
                    $ref->tag_name;
                    # When successfully accessing the tag
                    #  it's not out of scope yet...
                    $gone = 0;
                };
                $ref = undef if $gone;
            }
            my $elem = $self->find('body.done-parsing', scheme => 'css');
            return $elem ? 1 : 0;
        });
    return $self->body;
}

1;
