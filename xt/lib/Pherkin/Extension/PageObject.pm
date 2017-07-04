
=head1 NAME

Pherkin::Extension::PageObject - Pherkin extension for our PageObject testing

=head1 VERSION

0.01

=head1 SYNOPSIS



=cut

package Pherkin::Extension::PageObject;

use strict;
use warnings;

our $VERSION = '0.01';

use PageObject::Loader;
use Test::BDD::Cucumber::Extension;

use Moose;
extends 'Test::BDD::Cucumber::Extension';


=head1 Test::BDD::Cucumber::Extension protocol implementation

=over

=item step_directories

=cut

sub step_directories {
    return [ 'pageobject_steps/' ];
}


=item pre_scenario

=cut

sub pre_scenario {
    my ($self, $scenario, $feature_stash, $stash) = @_;

    $self->last_stash($stash);
    $stash->{ext_page} = $self;
}


=item post_scenario {

=cut

sub post_scenario {
    my ($self, $scenario, $feature_stash, $stash, $failed) = @_;

    $self->_save_screenshot($stash->{ext_wsl},"scenario", "post_scenario")
        if $failed;

    # break the ref-counting cycle
    $self->last_stash(undef);
}

=item post_step {

=cut

sub post_step {
    my ($self, $step, $step_context, $failed) = @_;

    $self->_save_screenshot($self->last_stash->{ext_wsl},"scenario", "post_step")
        if $failed;
}

=item _save_screenshot {

=cut

my $img_num = 0;

sub _save_screenshot {
    my ($self, $wsl, $event, $phase) = @_;

    my $img_name = "$event-$phase-" . ($img_num++) . '.png';
    open my $fh, ">", 'screens/' . $img_name;
    $wsl->driver->screenshot($fh);
    close $fh;
}

=back

=head1 ATTRIBUTES

=over

=item last_stash

=cut

has 'last_stash' => (is => 'rw');

=item page_object

=cut

has 'page' => (is => 'rw');

=back

=cut


1;
