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

use Digest::SHA qw(sha256_hex);
use Data::Printer {
    class =>   { show_methods => 'none', parents => 0 },
    filters => {
        'Selenium::Remote::Driver' => sub { $_[0]->remote_server_addr . ":" . $_[0]->port . $_[0]->wd_context_prefix },
        'PageObject::Root'         => sub { $_[0]->body },
        '_id'                      => sub { $_[0]->id },
        'Weasel::Session'          => sub { $_[0]->page },
    }
};
use Data::Dumper;

sub _get_sha {
    my $self = shift;
    my $sha = "";
    open my $fh, '>:encoding(UTF-8)', \$sha;
    $self->session->get_page_source($fh);
    close $fh;
    return sha256_hex($sha);
}

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
#    print $fh $self->session->get_page_source();
#    close $fh;
}

before clear_body => sub {
    my ($self) = @_;
    local @_;
    warn "clear_body++";
    for (my $i = 0 ; $i < 20 ; $i++ ) {
        my ($package, $filename, $line, $subroutine) = caller($i);
#        print STDERR $package . '::' . $subroutine . '#' . $line . "\n" if $package ne 'Class::MOP::Method';
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
#            return ($elem && $elem->is_displayed) ? 1 : 0;
            return $elem ? 1 : 0;
        });
    return $self->body;
}

1;
