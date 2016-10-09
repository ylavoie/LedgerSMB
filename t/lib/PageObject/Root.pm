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

use DateTime;

for my $func (qw(wait_for_body body has_body _build_body clear_body click_and_wait_for_body)) {
    before $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func++"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

for my $func (qw(wait_for_body body has_body _build_body clear_body click_and_wait_for_body)) {
    after $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func--"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

sub _build_body {
    my ($self) = @_;

    return $self->find('body.done-parsing', scheme => 'css');
}

sub _wait_for_stale {
  my ($self,$link) = @_;
  $self->session->wait_for(
      sub {
          try {
              # poll the link with an arbitrary call
              $link->tag_name;
              return 0;
          } catch {
            die $_ if ref($_) ne "HASH";
            warn $_->{cmd_return}->{error}->{code} if ref($_) eq "HASH" && $_->{cmd_return}->{error}->{code} ne "STALE_ELEMENT_REFERENCE";
            return $_->{cmd_return}->{error}->{code} eq "STALE_ELEMENT_REFERENCE";
          }
        }) if $link;
};

use Data::Printer;
sub click_and_wait_for_body {
    my ($self, @args) = @_;
    my $link = $self->find(@args);
    $link->click();

    $self->_wait_for_stale($link);
    $self->clear_body;
    $self->session->wait_for(
        sub {
          return $self->find('body.done-parsing', scheme => 'css') ? 1 : 0;
        });
    return $self->body;
}

sub wait_for_body {
    my ($self) = @_;
    my $ref;
    $ref = $self->body if $self->has_body;
    $self->clear_body;

    $self->_wait_for_stale($ref);
    $self->session->wait_for(
        sub {
            return $self->find('body.done-parsing', scheme => 'css') ? 1 : 0;
        });
    return $self->body;
}

1;
