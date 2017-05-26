package PageObject::App::Menu;

use strict;
use warnings;

use Carp;
use PageObject;
use MIME::Base64;
use Test::More;

use Module::Runtime qw(use_module);

use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'app-menu',
              './/div[@id="menudiv"]',
              tag_name => 'div',
              attributes => {
                  id => 'menudiv',
              });


my %menu_path_pageobject_map = (
        "AP > Add Transaction" => 'PageObject::App::AP::Transaction',
        "AP > Debit Invoice" => 'PageObject::App::AP::DebitInvoice',
        "AP > Debit Note" => 'PageObject::App::AP::Note',
        "AP > Import Batch" => 'PageObject::App::BatchImport',
        "AP > Reports > AP Aging" => '',
        "AP > Reports > Outstanding" => '',
        "AP > Reports > Vendor History" => '',
        "AP > Search" => 'PageObject::App::Search::AP',
        "AP > Vendor Invoice" => 'PageObject::App::AP::Invoice',
        "AP > Vouchers > AP Voucher" => '',
        "AP > Vouchers > Import AP Batch" => '',
        "AP > Vouchers > Invoice Vouchers" => '',

        "AR > Add Return" => 'PageObject::App::AR::Return',
        "AR > Add Transaction" => 'PageObject::App::AR::Transaction',
        "AR > Credit Invoice" => 'PageObject::App::AR::CreditInvoice',
        "AR > Credit Note" => 'PageObject::App::AR::Note',
        "AR > Import Batch" => 'PageObject::App::BatchImport',
        "AR > Reports > AR Aging" => '',
        "AR > Reports > Customer History" => '',
        "AR > Reports > Outstanding" => '',
        "AR > Sales Invoice" => 'PageObject::App::AR::Invoice',
        "AR > Search" => 'PageObject::App::Search::AR',
        "AR > Vouchers > AR Voucher" => '',
        "AR > Vouchers > Import AR Batch" => '',
        "AR > Vouchers > Invoice Vouchers" => '',

        "Budgets > Add Budget" => '',
        "Budgets > Search" => 'PageObject::App::Search::Budget',

        "Cash > Payment" => '',
        "Cash > Receipt" => '',
        "Cash > Reconciliation" => '',
        "Cash > Reports > Payments" => '',
        "Cash > Reports > Receipts" => '',
        "Cash > Reports > Reconciliation" => '',
        "Cash > Transfer" => '',
        "Cash > Use AR Overpayment" => '',
        "Cash > Use Overpayment" => '',
        "Cash > Vouchers > Payments" => '',
        "Cash > Vouchers > Receipts" => '',
        "Cash > Vouchers > Reverse AR Overpay" => '',
        "Cash > Vouchers > Reverse Overpay" => '',
        "Cash > Vouchers > Reverse Payment" => '',
        "Cash > Vouchers > Reverse Receipts" => '',

        "Contacts > Add Contact" => '',
        "Contacts > Search" => 'PageObject::App::Search::Contact',

        "Fixed Assets > Asset Classes > Add Class" => '',
        "Fixed Assets > Asset Classes > List Classes" => '',
        "Fixed Assets > Assets > Add Assets" => '',
        "Fixed Assets > Assets > Depreciate" => '',
        "Fixed Assets > Assets > Disposal" => '',
        "Fixed Assets > Assets > Import" => '',
        "Fixed Assets > Assets > Reports > Depreciation" => '',
        "Fixed Assets > Assets > Reports > Disposal" => '',
        "Fixed Assets > Assets > Reports > Net Book Value" => '',
        "Fixed Assets > Assets > Search Assets" => '',

        "General Journal > Add Accounts" => '',
        "General Journal > Chart of Accounts" => '',
        "General Journal > Import" => '',
        "General Journal > Import Chart" => '',
        "General Journal > Journal Entry" => '',
        "General Journal > Search and GL" => 'PageObject::App::Search::GL',
        "General Journal > Year End" => 'PageObject::App::Closing',

        "Goods and Services > Add Assembly" => 'PageObject::App::Parts::Assembly',
        "Goods and Services > Add Group" => '',
        "Goods and Services > Add Overhead" => 'PageObject::App::Parts::Overhead',
        "Goods and Services > Add Part" => 'PageObject::App::Parts::Part',
        "Goods and Services > Add Pricegroup" => '',
        "Goods and Services > Add Service" => 'PageObject::App::Parts::Service',
        "Goods and Services > Enter Inventory" => 'PageObject::App::Parts::AdjustSetup',
        "Goods and Services > Import Inventory" => '',
        "Goods and Services > Reports > Inventory Activity" => '',
        "Goods and Services > Search" => 'PageObject::App::Search::GoodsServices',
        "Goods and Services > Search Groups" => '',
        "Goods and Services > Search Pricegroups" => '',
        "Goods and Services > Stock Assembly" => '',
        "Goods and Services > Translations > Description" => '',
        "Goods and Services > Translations > Partsgroup" => '',

        "HR > Employees > Add Employee" => '',
        "HR > Employees > Search" => 'PageObject::App::Search::Contact',

        "Logout" => '',

        "New Window" => '',

        "Order Entry > Combine > Purchase Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Combine > Sales Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Generate > Purchase Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Generate > Sales Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Purchase Order" => 'PageObject::App::Orders::Purchase',
        "Order Entry > Reports > Purchase Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Reports > Sales Orders" => 'PageObject::App::Search::Order',
        "Order Entry > Sales Order" => 'PageObject::App::Orders::Sales',

        "Preferences" => '',

        "Quotations > Reports > Quotations" => 'PageObject::App::Search::Order',
        "Quotations > Reports > RFQs" => 'PageObject::App::Search::Order',
        "Quotations > RFQ" => '',

        "Recurring Transactions" => '',

        "Reports > Balance Sheet" => 'PageObject::App::Report::Filters::BalanceSheet',
        "Reports > Income Statement" => '',
        "Reports > Inventory and COGS" => '',
        "Reports > Trial Balance" => '',

        "Shipping > Receive" => '',
        "Shipping > Ship" => '',
        "Shipping > Transfer" => '',

        "System > Defaults" => 'PageObject::App::System::Defaults',
        "System > GIFI > Add GIFI" => '',
        "System > GIFI > Import GIFI" => '',
        "System > GIFI > List GIFI" => '',
        "System > HTML Templates > Invoicing" => '',
        "System > HTML Templates > Ordering" => '',
        "System > HTML Templates > Other" => '',
        "System > HTML Templates > Shipping" => '',
        "System > Language > Add Language" => '',
        "System > Language > List Languages" => '',
        "System > LaTeX Templates > Invoicing" => '',
        "System > LaTeX Templates > Ordering" => '',
        "System > LaTeX Templates > Other" => '',
        "System > LaTeX Templates > Shipping" => '',
        "System > Reporting Units" => '',
        "System > Sequences" => '',
        "System > Sessions" => '',
        "System > SIC > Add SIC" => '',
        "System > SIC > Import" => '',
        "System > SIC > List SIC" => '',
        "System > Taxes" => 'PageObject::App::System::Taxes',
        "System > Type of Business > Add Business" => '',
        "System > Type of Business > List Businesses" => '',
        "System > Warehouses > Add Warehouse" => '',
        "System > Warehouses > List Warehouse" => '',

        "Tax Forms > Add Tax Form" => '',
        "Tax Forms > List Tax Forms" => '',
        "Tax Forms > Reports" => '',

        "Timecards > Add Timecard" => '',
        "Timecards > Generate > Sales Orders" => '',
        "Timecards > Import" => '',
        "Timecards > Search" => '',
        "Timecards > Translations > Description" => '',

        "Transaction Approval > Batches" => '',
        "Transaction Approval > Drafts" => '',
        "Transaction Approval > Inventory" => 'PageObject::App::Parts::AdjustSearchUnapproved',
        "Transaction Approval > Reconciliation" => '',
        "Transaction Templates" => '',
    );


sub _verify {
    my ($self) = @_;

    my @logged_in_company =
        $self->find_all("//*[\@id='company_info' and string-length(normalize-space(text())) > 0]");
    my @logged_in_login =
        $self->find_all("//*[\@id='login_info' and string-length(normalize-space(text())) > 0]");

    return $self
        unless ((scalar(@logged_in_company) > 0)
              && scalar(@logged_in_login) > 0);
};


sub click_menu {
    my ($self, $path) = @_;
    my $root = $self->find("//*[\@id='top_menu']");

    my $item = $root;
    my $ul = '';

    my $tgt_class = $menu_path_pageobject_map{join(' > ', @$path)};
    if (!defined $tgt_class || $tgt_class eq '') {
        die join(' > ', @$path) . ' not implemented';
        return undef;
    }
    # make sure the widget is registered before resolving the Weasel widget
    ok(use_module($tgt_class),
       "$tgt_class can be 'use'-d dynamically");

    do {
        $item = $item->find(".$ul/li[./a[text()='$_']]");
        my $link = $item->find("./a");
        $link->click
            unless ($item->get_attribute('class') =~ /\bmenu_open\b/);

        $ul = '/ul';
    } for @$path;

    return $self->session->page->body->maindiv->wait_for_content;
}


__PACKAGE__->meta->make_immutable;

1;
