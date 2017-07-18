#!perl


use lib 'xt/lib';
use strict;
use warnings;


use Test::More;
use Test::BDD::Cucumber::StepFile;



###############
#
# Setup steps
#
###############

#Before Scenario, thus same as Background. Useless
#Before sub {
#  warn p @_;
#};

sub _page_find_displayed {
    my $self = shift @_;

    my @finds = S->{ext_wsl}->page->find_all(@_);
    @finds = grep { $_->is_displayed } @finds;
    return (shift @finds);
}

# Then qr/I see the new customer screen/, sub {
#   my $page = S->{ext_wsl}->page->body;
#
#   ok($page, "the browser page is the page named '$page_name'");
#   ok($pages{$page_name}, "the named page maps to a class name");
#   ok($page->isa($pages{$page_name}),
#      "the page is of expected class: " . ref $page);
# };

Then qr/one tab called (['"])(Person|Company)\1/, sub {
  my $tab = $2;
  ok(S->{ext_wsl}->page->find(".//*[\@role='tab' and text()='$tab']"),
    "the page has a tab named " . $tab)
};

# Dojo doesn't throw an exception but marks required fields as undone
Then qr/an error message should be thrown/, sub {
  TODO: {
    local $TODO = "Not implemented yet";
    todo_skip "Invalid Control code", 1;
  }
};

Then qr/I should get a valid Control Code/, sub {
  my $input = _page_find_displayed(S, '*labeled', text => 'Control Code');
  ok($input->get_attribute('value') =~ /[A-Z]-[0-9]+/,
    "the control code is valid")
};

Then qr/no credit accounts in the listing/, sub {
  my $input = _page_find_displayed(S, '*labeled', text => 'Number');
  ok($input->get_attribute('value') eq '',
    "the entity number is empty")
};

Then qr/I see a new line in the listing/, sub {
  my $input = _page_find_displayed(S, '*labeled', text => 'Number');
  ok($input->get_attribute('value') =~ /[0-9]+/,
    "the entity number is valid")
};

#When qr/I click on the Bank Accounts/, sub {
#  my $tab = $1;
#};

#When qr/I click on the Contact/, sub {
#  my $tab = $1;
#};

#And qr/click Save/, sub {
#};
#And qr/click continue/, sub {
#};
#And qr/enter a first name of (['"])Test\1/, sub {
#};
#And qr/enter a last name of ['"]Another test\1/, sub {
#};
#And qr/enter a name of of ['"]Testing, Inc\1/, sub {
#};
#And qr/enter a new account/, sub {
#};
#And qr/enter a new address/, sub {
#};
#And qr/enter a new note/, sub {
#};
#And qr/enter a new phone number/, sub {
#};
#And qr/one tab called ['"]Company\1/, sub {
#};
#And qr/select credit account/, sub {
#};
#And qr/select entity/, sub {
#};

#And qr/the Customer Number field is now filled in./, sub {
#};

#Then qr/I see a listing with a customer with a name like ['"]Test\1/, sub {
#};
#Then qr/I see a listing with a customer with a name of ['"]Testing, Inc\1/, sub {
#};
#Then qr/I see the /, sub {
#};
#Then qr/I see the new address in the table list/, sub {
#};
#Then qr/I see the new bank acount in the table list/, sub {
#};
#Then qr/I see the new note in the note list/, sub {
#};
#Then qr/I see the new phone number in the contact table list/, sub {
#};
#Then qr/I see the search filter screen./, sub {
#};
#Then qr/I see the vendor ECA record/, sub {
#};

#When qr/I click ['"]Save\1 on the Credit Account tab/, sub {
#  my $tab = $1;
#};
#When qr/I click on the Addresses tab/, sub {
#  my $tab = $1;
#};
#When qr/I click on the notes tab/, sub {
#  my $tab = $1;
#};
#When qr/I click the ['"]Test\1/, sub {
#};
#When qr/I click the ['"]Testing, Inc\1/, sub {
#};


1;
