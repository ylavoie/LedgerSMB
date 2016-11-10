#!/usr/bin/plackup 

BEGIN {
    if ( $ENV{'LSMB_WORKINGDIR'}
         && -f "$ENV{'LSMB_WORKINGDIR'}/lib/LedgerSMB.pm" ) {
        chdir $ENV{'LSMB_WORKINGDIR'};
    }    if ( $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development' ) {
        $ENV{PLACK_SERVER}       = 'Standalone';
        $ENV{METACPAN_WEB_DEBUG} = 1;
    }
}

package LedgerSMB::FCGI;

use FindBin;
use lib $FindBin::Bin . '/../lib';
use lib $FindBin::Bin . '/../old/lib';
use CGI::Emulate::PSGI;

# Application specific
use LedgerSMB;
use LedgerSMB::Auth;
use LedgerSMB::PSGI;
use LedgerSMB::Sysconfig;

use Log::Log4perl;

# Plack configuration
use Plack::Builder;
#use Plack::App::File;

# Optimization
#use Plack::Middleware::TemplateToolkit;

# Development specific
use Plack::Middleware::Debug::Log4perl;
use Plack::Middleware::InteractiveDebugger;
#use Plack::Middleware::Debug::TemplateToolkit;

Log::Log4perl::init(\$LedgerSMB::Sysconfig::log4perl_config);

builder {

    enable 'InteractiveDebugger';

#    enable 'ContentLength';

    enable 'Debug',  panels => [
            qw(Parameters Environment Response Log4perl Session),   # Timer Memory ModuleVersions PerlConfig
              [ 'DBITrace', level => 2 ],
#              [ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)], minimal => 1 ],
#           qw/Dancer::Settings Dancer::Logger Dancer::Version/
    ] if $ENV{PLACK_ENV} =~ "development";

#    enable 'Debug::TemplateToolkit';    # enable debug panel
    enable 'Log4perl', category => 'plack';

#    enable 'TemplateToolkit',
#        INCLUDE_PATH => 'UI',     # required
#        pass_through => 1;        # delegate missing templates to $app

    LedgerSMB::PSGI::setup_url_space(
            development => ($ENV{PLACK_ENV} eq 'development'),
            coverage => $ENV{COVERAGE}
            );
};

# -*- perl-mode -*-
