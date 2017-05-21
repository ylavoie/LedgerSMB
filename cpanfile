#!perl


requires 'perl', '5.14.0';

requires 'App::LedgerSMB::Admin', '0.05';
requires 'App::LedgerSMB::Admin::Database';
requires 'CGI::Emulate::PSGI';
requires 'CGI::Parse::PSGI';
requires 'Config::IniFiles';
requires 'DBD::Pg', '3.3.0';
requires 'DBI';
requires 'DateTime';
requires 'DateTime::Format::Strptime';
requires 'File::MimeInfo';
requires 'HTML::Entities';
requires 'HTML::Escape';
requires 'JSON';
recommends 'JSON::XS';
requires 'List::MoreUtils';
requires 'Locale::Maketext::Lexicon', '0.62';
requires 'Log::Log4perl';
requires 'LWP::Simple';
requires 'MIME::Lite';
requires 'Module::Runtime';
requires 'Moose';
requires 'Moose::Role';
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::NonMoose';
requires 'Number::Format';
requires 'PGObject', '1.403.2';
requires 'PGObject::Simple', '2.0.0';
requires 'PGObject::Simple::Role', '1.13.2';
requires 'PGObject::Type::BigFloat';
requires 'PGObject::Type::DateTime', '1.0.4';
requires 'PGObject::Type::ByteString', '1.1.1';
requires 'PGObject::Util::DBMethod';
requires 'PGObject::Util::DBAdmin', '0.09';
requires 'Plack::App::File';
requires 'Plack::App::REST';
requires 'Plack::Builder';
requires 'Plack::Builder::Conditionals';
requires 'Plack::Middleware::ConditionalGET';
requires 'Plack::Request';
requires 'Template', '2.14';
requires 'Template::Parser';
requires 'Template::Provider';
requires 'Try::Tiny';
requires 'Text::CSV';
requires 'XML::Simple';
requires 'namespace::autoclean';

recommends 'Math::BigInt::GMP';

feature 'starman', "Standalone Server w/Starman" =>
    sub {
        requires "Starman";
};

feature 'latex-pdf-images',
    "Size detection for images for embedding in LaTeX templates" =>
    sub {
        requires "Image::Size";
};

feature 'edi', "X12 EDI support" =>
    sub {
        requires 'X12::Parser';
        requires 'Path::Class';
};

feature 'latex-pdf-ps', "PDF and PostScript output" =>
    sub {
        requires 'LaTeX::Driver', '0.300.2';
        requires 'Template::Latex', '3.08';
        requires 'TeX::Encode';
};

feature 'openoffice', "OpenOffice.org output" =>
    sub {
        requires "XML::Twig";
        requires "OpenOffice::OODoc";
        requires 'OpenOffice::OODoc::Styles';
};

feature 'xls', "Microsoft Excel" =>
    sub {
        requires 'Spreadsheet::WriteExcel';
        requires 'Excel::Writer::XLSX';
};

feature 'debug', "Debug pane" =>
    sub {
        recommends 'Devel::NYTProf';    # No explicit require for debug pane, handled internaly
        recommends 'Module::Versions';  # No explicit require for debug pane, handled internaly
        recommends 'Plack::Middleware::Debug::Log4perl';                # Optional
        recommends 'Plack::Middleware::Debug::Profiler::NYTProf';       # Optional
        recommends 'Plack::Middleware::InteractiveDebugger';            # Optional
};

# Even with cpanm --notest, 'test' target of --installdeps
# will be included, but not tested
on 'develop' => sub {
    #requires 'COATest';
    requires 'DBI';
    requires 'File::Find::Rule';
    requires 'File::Find::Rule::Perl';
    requires 'File::Util';
    recommends 'HTML::Lint';    # Provided by HTML::Lint::Pluggable
    #requires 'HTML::Lint::Parser', '>= 2.26';
    requires 'HTML::Lint::Pluggable';
    recommends 'HTML::Lint::Pluggable::HTML5';      # Dynamic Plugin
    recommends 'HTML::Lint::Pluggable::WhiteList';  # Dynamic Plugin
    recommends 'Linux::Inotify2';
    requires 'Log::Log4perl';
    requires 'MIME::Base64';
    requires 'Module::CPANfile';
    requires 'Module::Runtime';
    requires 'Moose';
    requires 'Perl::Critic';
    requires 'Pherkin::Extension::Weasel', '0.02';
    recommends 'Plack::Middleware::Pod';
    requires 'Selenium::Remote::Driver';
    requires 'Selenium::Remote::WDKeys';
    requires 'TAP::Parser::SourceHandler::pgTAP';
    requires 'Template', '2.14';
    #requires 'Test::BDD::Cucumber', '>= 0.52';
    requires 'Test::BDD::Cucumber::Extension';
    requires 'Test::BDD::Cucumber::StepFile';
    requires 'Test::Class::Moose';
    requires 'Test::Class::Moose::Load';
    requires 'Test::Class::Moose::Runner';
    #requires 'Test::Class::Moose::Role';
    requires 'Test::Class::Moose::Role::ParameterizedInstances';
    requires 'Test::More';  # We should pick More or Most, why 2?
    requires 'Test::Most';
    requires 'Test::Dependencies', '>= 0.20';
    #requires 'Test::Harness', '>= 3.36';
    requires 'Try::Tiny';
    requires 'Weasel', '>= 0.11';
    requires 'Weasel::Driver::Selenium2', '>= 0.05';
    requires 'Weasel::Element';
    requires 'Weasel::Element::Document';
    requires 'Weasel::FindExpanders';
    requires 'Weasel::FindExpanders::Dojo';
    requires 'Weasel::FindExpanders::HTML';
    requires 'Weasel::WidgetHandlers';
    requires 'Weasel::Widgets::Dojo';
    requires 'Weasel::Widgets::HTML';
    requires 'YAML::Syck';
};

# No build related dependencies
on 'build' => sub {
};

# No configure related dependencies
on 'configure' => sub {
};

# Required only by our tests
# We need https://github.com/miyagawa/cpanminus/issues/502 to be fixed
# for this to work.
on 'test' => sub {
    requires 'DBI';
    requires 'Digest::SHA';
    requires 'FindBin';
    requires 'Log::Log4perl';
    requires 'MIME::Base64';
    requires 'Test::Exception';
    requires 'Test::More';
    requires 'Test::Trap';
};
