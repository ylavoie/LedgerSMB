#!perl


use strict;
use warnings;

use Module::Runtime qw/ use_module /;

use Test::More;
use Test::BDD::Cucumber::StepFile;

my %pages = (
    "setup login"         => "PageObject::Setup::Login",
    "company creation"    => "PageObject::Setup::Admin",
    "user creation"       => "PageObject::Setup::CreateUser",
    "setup confirmation"  => "PageObject::Setup::OperationConfirmation",
    "application login"   => "PageObject::App::Login",
    "setup admin"         => "PageObject::Setup::Admin",
    "setup user list"     => "PageObject::Setup::UsersList",
    "edit user"           => "PageObject::Setup::EditUser",
    );

When qr/I navigate to the application root/, sub {
    my $module = "PageObject::App::Login";

    use_module($module);
    S->{page} = $module->open(S->{ext_wsl})->verify;
};

When qr/I navigate to the (.*) page/, sub {
    my $page = $1;
    die "Unknown page '$page'"
        unless exists $pages{$page};
#    ok(exists $pages{$page},"Page " . $page . "is handled");

    use_module($pages{$page});
    S->{page} = $pages{$page}->open(S->{ext_wsl})->verify;
};

Then qr/I should see the (.*) page/, sub {
    my $page_name = $1;
    die "Unknown page '$page_name'"
        unless exists $pages{$page_name};

    my $page = S->{ext_wsl}->page->body->verify;
    ok($page, "the browser page is the page named '$page_name'");
    ok($pages{$page_name}, "the named page maps to a class name");
    ok($page->isa($pages{$page_name}),
       "the page is of expected class: " . ref $page);
};

use Data::Dumper;

When qr/I navigate the menu and select the item at "(.*)"/, sub {
    my @path = split /[\n\s\t]*>[\n\s\t]*/, $1;

    S->{ext_wsl}->page->body->menu->click_menu(\@path);
};

my %screens = (
#    'Contacts Add Contact' => 'PageObject::App::Contacts::Add',
    'Add' => 'PageObject::App::Contacts::Add',
    'Contact search' => 'PageObject::App::Search::Contact',
    'AR transaction entry' => 'PageObject::App::AR::Transaction',
    'AR invoice entry' => 'PageObject::App::AR::Invoice',
    'AR note entry' => 'PageObject::App::AR::Note',
    'AR credit invoice entry' => 'PageObject::App::AR::CreditInvoice',
    'AR returns' => 'PageObject::App::AR::Return',
    'AR search' => 'PageObject::App::Search::AR',
    'AP transaction entry' => 'PageObject::App::AP::Transaction',
    'AP invoice entry' => 'PageObject::App::AP::Invoice',
    'AP note entry' => 'PageObject::App::AP::Note',
    'AP debit invoice entry' => 'PageObject::App::AP::DebitInvoice',
    'AP search' => 'PageObject::App::Search::AP',
    'Batch import' => 'PageObject::App::BatchImport',
    'Budget search' => 'PageObject::App::Search::Budget',
    'Employee search' => 'PageObject::App::Search::Contact',
    'Sales order search' => 'PageObject::App::Search::Order',
    'Purchase order search' => 'PageObject::App::Search::Order',
    'Sales order entry' => 'PageObject::App::Orders::Sales',
    'Purchase order entry' => 'PageObject::App::Orders::Purchase',
    'generate sales order' => 'PageObject::App::Search::Order',
    'generate purchase order' => 'PageObject::App::Search::Order',
    'combine sales order' => 'PageObject::App::Search::Order',
    'combine purchase order' => 'PageObject::App::Search::Order',
    'Quotation search' => 'PageObject::App::Search::Order',
    'RFQ search' => 'PageObject::App::Search::Order',
    'GL search' => 'PageObject::App::Search::GL',
    'year-end confirmation' => 'PageObject::App::ClosingConfirm',
    'part entry' => 'PageObject::App::Parts::Part',
    'service entry' => 'PageObject::App::Parts::Service',
    'assembly entry' => 'PageObject::App::Parts::Assembly',
    'overhead entry' => 'PageObject::App::Parts::Overhead',
    'system defaults' => 'PageObject::App::System::Defaults',
    'system taxes' => 'PageObject::App::System::Taxes',
    );

Then qr/I should see the (.*) screen/, sub {
    my $page_name = $1;
    die "Unknown screen '$page_name'"
        unless exists $screens{$page_name};

    my $page;
    S->{ext_wsl}->wait_for(
        sub {
            $page = S->{ext_wsl}->page->body->maindiv->content;
            return $page && $page->isa($screens{$page_name});
        });
    ok($page, "the browser screen is the screen named '$page_name'");
    ok($screens{$page_name}, "the named screen maps to a class name");
    ok($page->isa($screens{$page_name}),
       "the screen is of expected class: " . ref $page);
};

When qr/I select the "(.*)" tab/, sub {
    S->{ext_wsl}->page->find(".//*[\@role='tab' and text()='$1']")->click;
};

Then qr/ I see the '(.+)' Tab/, sub {
  my $tab = $1;
  ok(S->{ext_wsl}->page->find(".//*[\@role='tab' and text()='$tab']"),
    "the page has a tab named " . $tab)
};


1;
