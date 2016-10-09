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


my %img_num = ();

sub _save_screenshot {
    my ($self, $event, $phase) = @_;

    $img_num{$event}++ if $phase !~ /post/;
    my $img_name = "$event-$phase-" . $img_num{$event} . '.png';
    CORE::open my $fh, ">", "screens" . '/' . $img_name;
    $self->session->screenshot($fh);
    close $fh;

#    my $html_name = "$event-$phase-" . $img_num{$event} . '.html';
#    CORE::open $fh, ">:utf8", "screens" . '/' . $html_name;
#    $self->session->get_page_source($fh);
#    close $fh;
}

use DateTime;

for my $func (qw(wait_for_page click)) {
    before $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func++"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

for my $func (qw(wait_for_page click)) {
    after $func => sub {
        warn DateTime->now->ymd . " " . DateTime->now->hms . " " . __PACKAGE__."::$func--"
            if(defined $ENV{'DEBUG_WEASEL'});
    };
}

sub wait_for_page {
    my ($self, $ref) = @_;

    $self->session->wait_for_stale($ref);
    $self->session->wait_for(
        sub {
            $self->_save_screenshot("find","pre");
            my $css = $self->session->page
                ->find('body.done-parsing', scheme => 'css');
            $self->_save_screenshot("find","post");
            return defined $css;
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
