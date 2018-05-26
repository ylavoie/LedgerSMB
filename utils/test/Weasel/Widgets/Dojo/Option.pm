
package Weasel::Widgets::Dojo::Option;

use strict;
use warnings;

use Moose;
extends 'Weasel::Element';

use Weasel::WidgetHandlers qw/ register_widget_handler /;

register_widget_handler(__PACKAGE__, 'Dojo',
                        tag_name => 'tr',
                        attributes => {
                            role => 'option',
                        });


sub _option_popup {
    my ($self) = @_;

    # Note, this assumes there are no pop-ups nested in the DOM,
    # which from experimentation I believe to be true at this point
    my $popup = $self->find('ancestor::*[@dijitpopupparent]');

    return $popup;
}

#use Data::Printer;
use POSIX qw(strftime);
sub _getTime
{
    my $format = $_[0] || '%H:%M:%S %p';
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return strftime($format, $sec, $min, $hour, $wday, $mon, $year);
}

sub click {
    my ($self) = @_;
    my $popup = $self->_option_popup;

    if (! $popup->is_displayed) {
        my $id = $popup->get_attribute('dijitpopupparent');
        $self->find("//*[\@id='$id']")->click; # pop up the selector
#        $self->session->wait_for(
#            sub {
#                my $class = $self->find("//*[\@id='$id']")->get_attribute('class');
#                #warn _getTime() . ' ' . np $class;
#                return $class =~ /dijitSelectOpened/;
#        });
    }

    #TODO: This doesn't work in Firefox because of
    #https://github.com/mozilla/geckodriver/issues/1228
    if ( $self->session->driver->{caps}{browser_name} ne 'firefox') {
        $self->SUPER::click;
    } else {
        #Use this instead for the moment
        $self->SUPER::send_keys("\n");
    }

    return;
}


1;
