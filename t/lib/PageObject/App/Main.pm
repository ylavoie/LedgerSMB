package PageObject::App::Main;

use strict;
use warnings;

use PageObject;
use Try::Tiny;

use Moose;
extends 'PageObject';


__PACKAGE__->self_register(
              'app-main',
              './/div[@id="maindiv"]',
              tag_name => 'div',
              attributes => {
                  id => 'maindiv',
              });


has content => (is => 'rw',
                isa => 'PageObject',
                builder => '_build_content',
                predicate => 'has_content',
                reader => '_get_content',
                writer => '_set_content',
                clearer => 'clear_content',
                lazy => 1);

sub content {
    my ($self, $new_value) = @_;

    return $self->_set_content($new_value) if $new_value;

    my $gone = 1;
    try {
        $self->_get_content->tag_name
            if $self->has_content;
        # we're still here?
        $gone = 0;
    };
    $self->clear_content if $gone; # force builder

    return $self->_get_content;
}

sub _build_content {
    my ($self) = @_;

    my @found = $self->find_all('./*'); # find any immediate child
    die "#maindiv is expected to have exactly one child node"
        unless scalar(@found) == 1;

    my $found = shift @found;
    die "the immediate child node of #maindiv isn't recognised as a PageObject"
        unless $found->isa("PageObject");

    return $found;
}

before wait_for_content => sub {
    warn "wait_for_content++";
};

after wait_for_content => sub {
    warn "wait_for_content--";
};

# Note: copy of PageObject::Root::wait_for_body()
sub wait_for_content {
    my ($self) = @_;
    my $ref;
    $ref = $self->content if $self->has_content;
    $self->clear_content;

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
                return 0; # Not done yet
            }
            my $elem = $self->session->page->find('#maindiv.done-parsing',
                                                  scheme => 'css');
            return ($elem && $elem->is_displayed) ? 1 : 0;
        });
    return $self->content;
}


sub _verify {
    my ($self) = @_;

    $self->content->verify;
    return $self;
};



__PACKAGE__->meta->make_immutable;

1;
