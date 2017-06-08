package PageObject;

use strict;
use warnings;

use Carp;
use Module::Runtime qw(use_module);

use Moose;
extends 'Weasel::Element';

use Weasel::FindExpanders qw/ register_find_expander /;
use Weasel::FindExpanders::Dojo;
use Weasel::FindExpanders::HTML;

use Weasel::WidgetHandlers qw/ register_widget_handler /;
use Weasel::Widgets::Dojo;
use Weasel::Widgets::HTML;


sub self_register {
    my ($class, $mnemonic, $xpath, %widget_options) = @_;
    my $xpath_fn = (ref $xpath) ? $xpath : sub { return $xpath };

    {
        no strict 'refs';
        no warnings 'once';
        ${"${class}::MNEMONIC"} = $mnemonic;
    }
    register_find_expander($mnemonic, 'LedgerSMB', $xpath_fn);
    register_widget_handler($class, 'LedgerSMB', %widget_options);
}

sub open {
    my ($class, $session) = @_;

    $session->get($class->url);

    $session->page->wait_for_body;
    return $session->page->body;
}

sub field_types { return {}; }

sub url { croak "Abstract method 'PageObject::url' called"; }


use Data::Printer;
sub wait_for_page {
    my ($self, $ref) = @_;

    $self->session->wait_for(
        sub {

            if ($ref) {
                local $@;

                warn p $ref;
                my $ref_id = $self->find_element_by_id($ref->id->id);
                warn p $ref_id;
                $ref = undef if !$ref_id;
                return 0;
#                return $ref_id
#                    || $old_id ? $ref_id->id ne $ref->id->id : 0;
            }
            else {
#                warn p $self;
#                warn p $self->_id;
                $self->session->page
                    ->find('body.done-parsing', scheme => 'css');
            }
        });
}

sub verify {
    my ($self, $ref) = @_;

    $self->wait_for_page($ref);
    $self->_verify;
};

sub _verify { croak "Abstract method 'PageObject::verify' called"; }



__PACKAGE__->meta->make_immutable;

1;
