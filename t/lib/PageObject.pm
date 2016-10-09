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

    my $html_name = "$event-$phase-" . $img_num{$event} . '.html';
    CORE::open $fh, ">:utf8", "screens" . '/' . $html_name;
    print $fh $self->session->get_page_source();
    close $fh;
}

use DateTime;

before click => sub {
    warn DateTime->now->ymd . " " . DateTime->now->hms . " PageObject::click++"
        if(defined $ENV{'DEBUG_WEASEL'});
};

after click => sub {
    warn DateTime->now->ymd . " " . DateTime->now->hms . " PageObject::click--"
        if(defined $ENV{'DEBUG_WEASEL'});
};

before wait_for_page => sub {
    warn DateTime->now->ymd . " " . DateTime->now->hms . " PageObject::wait_for_page++"
        if(defined $ENV{'DEBUG_WEASEL'});
};

after wait_for_page => sub {
    warn DateTime->now->ymd . " " . DateTime->now->hms . " PageObject::wait_for_page--"
        if(defined $ENV{'DEBUG_WEASEL'});
};

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

sub wait_for_page {
    my ($self, $ref) = @_;

    $self->_wait_for_stale($ref);
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
