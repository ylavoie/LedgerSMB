package PageObject::App::Contacts::Add;

use Moose;

use Carp;
use PageObject::App::Contacts;

extends 'PageObject::App::Contacts';

__PACKAGE__->self_register(
              'add-contact',
              './/form[@id="add-contact"]',
              tag_name => 'form',
              attributes => {
                  id => 'add-contact',
              });


my $page_heading = 'Add';

#for my $func (qw(_verify)) {
#    before $func => sub {
#        warn __PACKAGE__."::$func++";
#    };
#}

#for my $func (qw(_verify)) {
#    before $func => sub {
#        warn __PACKAGE__."::$func--";
#    };
#}

sub _verify {
    my ($self) = @_;

#    $self->find(".//*[\@class='listtop'
#                      and text()='$page_heading']");

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
