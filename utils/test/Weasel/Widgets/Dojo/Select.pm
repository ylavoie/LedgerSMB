
package Weasel::Widgets::Dojo::Select;

use strict;
use warnings;

use Weasel::Widgets::HTML::Select;
use Weasel::WidgetHandlers qw/ register_widget_handler /;

use Moose;
extends 'Weasel::Widgets::HTML::Select';

register_widget_handler(__PACKAGE__, 'Dojo',
                        tag_name => 'table',
                        classes => [ 'dijitSelect' ],
                        attributes => {
                            role => 'listbox',
                        },
    );


#use Data::Printer;
use POSIX qw(strftime);
sub _getTime
{
    my $format = $_[0] || '%H:%M:%S %p';
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return strftime($format, $sec, $min, $hour, $wday, $mon, $year);
}

sub _option_popup {
    my ($self) = @_;
    my $id = $self->get_attribute('id');
    my $page = $self->session->page;

    my @rv = $page->find_all("//div[\@dijitpopupparent='$id']");

    if (! @rv) { # no elements returned, while we expect one; create the popup
        # make sure the popup gets created by clicking twice (pop up+pop down)
        $self->click;
#        $self->session->wait_for(
#            sub {
#                my $class = $self->get_attribute('class');
#                #warn _getTime() . ' ' . np $class;
#                return $class =~ /dijitSelectOpened/;
#        });
        $self->click;
#        $self->session->wait_for(
#            sub {
#                my $class = $self->get_attribute('class');
#                #warn _getTime() . ' ' . np $class;
#                return $class !~ /dijitSelectOpened/;
#        });

        @rv = $page->find_all("//div[\@dijitpopupparent='$id']");
    }

    return (shift @rv);
}

sub get_attribute {
    my ($self, $name) = @_;

    if ($name eq 'value') {
        return $self->find('.//input[@type="hidden"
                              and @data-dojo-attach-point="valueNode"]')
            ->get_attribute('value');
    }
    else {
        return $self->SUPER::get_attribute($name);
    }
}

sub get_property {
    my ($self, $name) = @_;

    if ($name eq 'value') {
        return $self->find('.//input[@type="hidden"
                              and @data-dojo-attach-point="valueNode"]')
            ->get_property('value');
    }
    else {
        return $self->SUPER::get_property($name);
    }
}

1;
