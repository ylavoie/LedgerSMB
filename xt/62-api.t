#!perl -T
use strict;
use warnings; # FATAL => 'all';
use Test::More;
use Plack::Builder;
use Plack::Test;
use HTTP::Request::Common;
use LedgerSMB::REST::MenuREST;
use JSON::Validator;

my $app = builder {
                    mount "/api" => builder {
                        mount '/menus' => LedgerSMB::REST::MenuREST->new()->to_app;
                    };
                  };

test_psgi app => $app, client => sub {
    my $cb = shift;

    my ($res,$test) ;

    TODO: {
        $test = "/api";
        $res = $cb->(GET "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [404, "Content-Type: text/plain\n", 'Not Found'], "GET $test" );

        my $validator = JSON::Validator->new;
        $validator->schema(
        {
          id        => "integer",
          args      =>  {
                            type  => "array",
                            items => { type => "string" },
                        },
          children  =>  {
                            type  => "array",
                            items => { type =>"number", minimum => 0 },
                        },
          parent    => anyOf => [
                                {type => "string", maxLength => 5},
                                {type => "number", minimum => 0}
                             ],
          level     => {type => "number", minimum => 0},
          label     => "string",
          path      => "string",
          position  => {type => "number", minimum => 0},
          preferred => {type => "number", minimum => 0},
          menu      => {type => "number", minimum => 0}
          }
        );

        $test = "/api/menus";
        $res = $cb->(GET "http://localhost$test");
        is($res->code,200,$test);
        is($res->headers->as_string,"Content-Type: application/json\n",$test);
        my @errors = $validator->validate($res->content);
        is(0+@errors,0,$test);

        $test = "/api/menus/1";
        $res = $cb->(GET "http://localhost$test");
        is($res->code,200,$test);
        is($res->headers->as_string,"Content-Type: application/json\n",$test);
        @errors = $validator->validate($res->content);
        is(0+@errors,0,$test);

        $test = "/api/menus/preferred";
        $res = $cb->(PUT "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [400, "Content-Type: text/plain\n", 'Bad Request'], "PUT $test" );

        $test = "/api/menus/preferred=0";
        $res = $cb->(PUT "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [200, "Content-Type: text/plain\n", "Not Found"], "PUT /api/menus/preferred=0" );

        $test = "/api/menus/1?preferred=0";
        $res = $cb->(PUT "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [200, "Content-Type: text/plain\n", 'Not Found'], "PUT $test" );

        $test = "/api/menus/1?preferred=1";
        $res = $cb->(PUT "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [200, "Content-Type: text/plain\n", 'Not Found'], "PUT $test" );

        $test = "/api/menus/1?preferred=2";
        $res = $cb->(PUT "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [404, "Content-Type: text/plain\n", 'Not Found'], "PUT $test" );

        $test = "/api/menus/1?preferred=0";
        $res = $cb->(POST "http://localhost$test");
        is_deeply( [$res->code, $res->headers->as_string, $res->content], [405, "Content-Type: text/plain\n", 'Method Not Allowed'], "POST $test" );

    #    for my $name in (qw(DELETE TRACE OPTIONS PATCH HEAD)) {
    #       $test = "/api/menus/1";
    #       $res = $cb->($name "http://localhost$test");
    #       is_deeply( [$res->code, $res->headers->as_string, $res->content], [405, "Content-Type: text/plain\n", 'Not Found'], "$name $test" );
    #    }
    }
};

done_testing;
