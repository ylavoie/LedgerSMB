package PageObject::App::Cash::Vouchers::Payments::Detail;

use strict;
use warnings;

use Carp;
use PageObject;

use Moose;
use namespace::autoclean;
extends 'PageObject';

__PACKAGE__->self_register(
    'cash-vouchers-payments-detail',
    './/div[@id="payments-detail"]',
    tag_name => 'div',
    attributes => {
        id => 'payments-detail',
    }
);


# payment_rows()
#
# Returns an arrayref of rows in the table of payment lines.

sub payment_rows {
    my $self = shift;
    my $rows = $self->find_all('//table[@id="payments-table"]/tbody/tr');

    return $rows;
}


# parse_payment_row($tr_element)
#
# Given a tr element representing a payment row from the payment
# detail table, return a hashref representing the field text.

sub parse_payment_row {
    my $self = shift;
    my $row = shift;
    my $rv = {
        'Name' => $row->find('./td[@class="entity_name"]')->get_text,
        'Invoice Total' => $row->find('./td[@class="invoice"]')->get_text,
        'Source' => $row->find('//input[@title="Source"]')->get_property('value'),
    };

    return $rv;
}

# find_payment_row($wanted)
#
# Returns the payment detail table <tr> element with fields
# matching those specified in supplied $wanted hashref.
#
# For example:
# my $element = find_payment_row({
#     'Source' => '1001',
#     'Name' => 'Acme Widgets',
#     'Invoice Total' => '100.00 USD'
# });

sub find_payment_row {
    my $self = shift;
    my $wanted = shift;

    ROW: foreach my $element(@{$self->payment_rows}) {
        my $row = $self->parse_payment_row($element);

        TEST: foreach my $key(keys %{$wanted}) {
            defined $row->{$key} && $row->{$key} eq $wanted->{$key}
                or next ROW;
        }

        # Stop searching as soon as we find a matching row
        return $element;
    }

    return;
}


# find_invoice_detail_table($wanted)
#
# Returns the invoice detail subtable <table> element for the
# vendor payment row with fields matching thos specified in the
# supplied $wanted hashref.
#
# For example:
# my $subtable = $find_invoice_detail_table({
#     'Name' => 'Acme Widgets',
# });

sub find_invoice_detail_table {
    my $self = shift;
    my $wanted = shift;
    my $payment_row = $self->find_payment_row($wanted);
    my $detail_table = $payment_row->find(
        './following-sibling::tr/td[@class="invoice_detail_list"]/table'
    );
    return $detail_table;
}


# invoice_detail_rows({vendor => $vendor})
#
# Returns an arrayref of rows in the table of payment lines for
# the specified vendor name.

sub invoice_detail_rows {
    my $self = shift;
    my $args = shift;
    my $table = $self->find_invoice_detail_table({
        Name => $args->{vendor}
    });
    my $rows = $table->find_all('./tbody/tr');
    return $rows;
}



# parse_invoice_detail_row($tr_element)
#
# Given a tr element representing an invoice detail row from a
# subtable of the payment detail table, return a hashref representing
# the field text.

sub parse_invoice_detail_row {
    my $self = shift;
    my $row = shift;
    my $rv = {
        'Date' => $row->find('./td[@class="invoice_date_list"]')->get_text,
        'Invoice Number' => $row->find('./td[@class="invoice_list"]')->get_text,
        'Total' => $row->find('./td[@class="total_due_list"]')->get_text,
        'Paid' => $row->find('./td[@class="paid_list"]')->get_text,
        'Discount' => $row->find('./td[@class="discount_list"]')->get_text,
        'Net Due' => $row->find('./td[@class="net_due_list"]')->get_text,
        'To Pay' => $row->find(
            './td[@class="to_pay_list"]/div/div/input[contains(@name, "payment_")]'
        )->get_property('value'),
    };

    return $rv;
}


# find_invoice_detail_row({vendor => $vendor, wanted => $wanted})
#
# Returns the payment detail table <tr> element with fields
# matching those specified in supplied $wanted hashref for the
# given vendor name.
#
# For example:
# my $element = find_payment_row({
#     vendor => 'Acme Widgets',
#     wanted => {
#         'Date' => '2018-01-01',
#         'Invoice Number' => 'I1001',
#     },
# });

sub find_invoice_detail_row {
    my $self = shift;
    my $args = shift;

    my $rows = $self->invoice_detail_rows({
        vendor => $args->{vendor}
    });

    ROW: foreach my $element(@{$rows}) {
        my $row = $self->parse_invoice_detail_row($element);

        TEST: foreach my $key(keys %{$args->{wanted}}) {
            defined $row->{$key} && $row->{$key} eq $args->{wanted}->{$key}
                or next ROW;
        }

        # Stop searching as soon as we find a matching row
        return $element;
    }

    return;
}


sub _verify {
    my ($self) = @_;

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
