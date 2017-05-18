package LedgerSMB::MenuREST;

use strict;
use warnings;

use parent qw(Plack::App::REST);

=head1 NAME

LedgerSMB::MenuREST - REST Server for LedgerSMB Menus

=head1 SYNOPSIS

use LedgerSMB::MenuREST;
REST routines will be transparently become available with Plack::App::REST,
as long as their names match the REST commands

=cut


sub GET {
    my ($self, $env, $data) = @_;

    $env->{SCRIPT_NAME} = "/menu.pl";
    $env->{QUERY_STRING} = "action=menuitems_json";

    foreach my $param ( @{$env->{'rest.ids'}} ) {
        $env->{QUERY_STRING} .= "&id=$param"
            if $param && $param =~ /^[0-9]+$/;
    }
    my @res = @{LedgerSMB::PSGI::psgi_app($env)};
    return ($res[2], $res[1]);
}

sub PUT {
    my ($self, $env, $data) = @_;

    $env->{SCRIPT_NAME} = "/menu.pl";
    $env->{QUERY_STRING} = "action=menuitems_json";

    foreach my $param ( @{$env->{'rest.ids'}} ) {
        $env->{QUERY_STRING} .= "&id=$param"
            if $param && $param =~ /^[0-9]+$/;
    }
    my @res = @{LedgerSMB::PSGI::psgi_app($env)};
    return ($res[2], $res[1]);
}

1;
