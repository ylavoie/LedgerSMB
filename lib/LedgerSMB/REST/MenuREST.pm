package LedgerSMB::REST::MenuREST;

use strict;
use warnings;

use parent qw(Plack::App::REST);
use Plack::Request; # Because we still do not use it globally
use JSON;

=head1 NAME

LedgerSMB::REST::MenuREST - REST Server for LedgerSMB Menus

=head1 SYNOPSIS

use LedgerSMB::REST::MenuREST;

REST routines will be transparently become available with Plack::App::REST,
as long as their names match the REST commands

Allowed syntax:
    GET /api/menus                  Returns the whole menu tree
    GET /api/menus/n                Returns item id n
    PUT /api/menus/n/preferred=[01] Puts menu n in user preferences

=cut


=head1 FUNCTIONS

=over

=item GET

Implement GET function for menus

=cut

sub GET {
    my ($self, $env, $data) = @_;

    $env->{SCRIPT_NAME} = "/menu.pl";
    $env->{QUERY_STRING} = "action=menuitems_json";

    HTTP::Exception->throw(400)
        if $env->{'rest.ids'} && @{$env->{'rest.ids'}} > 1; # 0 or 1 id only

    foreach my $param ( @{$env->{'rest.ids'}} ) {
        if ($param && $param =~ /^[0-9]+$/) {
            $env->{QUERY_STRING} .= "&id=$param";
        } else {
            HTTP::Exception->throw(400); # Bad request, Unknown parameter
        }
    }
    my @res = @{LedgerSMB::PSGI::psgi_app($env)};
    return ($res[2], $res[1]);
}

=item PUT

Implement GET function for menus

=cut

sub _request_content {
    return unless defined $_[0]->{CONTENT_LENGTH};
    return (Plack::Request->new($_[0])->content => $_[0]->{CONTENT_TYPE});
}

sub PUT {
    my ($self, $env, $data) = @_;

    my ($content,$type);

    HTTP::Exception->throw(400)
        if !$env->{'rest.ids'} || !@{$env->{'rest.ids'}}; # No parameters

    $env->{SCRIPT_NAME} = "/menu.pl";
    $env->{QUERY_STRING} = "action=menuitems_json";

    foreach my $param ( @{$env->{'rest.ids'}} ) {
        if ($param && $param =~ /^[0-9]+$/) {
            $env->{QUERY_STRING} .= "&id=$param";
        } else {
            HTTP::Exception->throw(400); # Bad request, Unknown parameter
        }
    }

    ($content => $type) = _request_content($env); # get content and MIME type
    $content = decode_json($content);

    if ($content && $content->{preferred} =~ /([01])/) {
        $env->{QUERY_STRING} .= "&preferred=$1";
    } else {
            HTTP::Exception->throw(404);
    };
    my @res = @{LedgerSMB::PSGI::psgi_app($env)};
    return ($res[2], $res[1]);
}

=back

=cut

1;
