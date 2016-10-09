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

use DateTime;

for my $func (qw(wait_for_content content _get_content _set_content has_content _build_content clear_content _verify)) {
    before $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func++"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

for my $func (qw(wait_for_content content _get_content _set_content has_content _build_content clear_content _verify)) {
    after $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func--"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}


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

sub click_and_wait_for_content {
    my ($self, @args) = @_;
    my $link = $self->find(@args);
    $link->click();

    $self->session->wait_for_stale($link);
    $self->session->wait_for(
        sub {
            my $elem = $self->session->page->find('#maindiv.done-parsing',
                                                  scheme => 'css');
            return ($elem && $elem->is_displayed) ? 1 : 0;
        });
    return $self->content;
}

sub wait_for_content {
    my ($self) = @_;
    my $old_content;
    $old_content = $self->content if $self->has_content;
    $self->clear_content;

    $self->session->wait_for_stale($old_content);
    $self->session->wait_for(
        sub {
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
