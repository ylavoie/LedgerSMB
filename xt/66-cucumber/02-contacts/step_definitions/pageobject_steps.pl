#!perl


use lib 't/lib';
use strict;
use warnings;


use Test::More;
use Test::BDD::Cucumber::StepFile;



###############
#
# Setup steps
#
###############

When qr/I click on the Add Contact menu entry/, sub {
  my @path = split /[\n\s\t]*>[\n\s\t]*/, 'Contacts > Add Contact';

  S->{ext_wsl}->page->body->menu->click_menu(\@path);
  S->{ext_wsl}->page->body->verify;
};

# Then qr/I see the new customer screen/, sub {
#   my $page = S->{ext_wsl}->page->body;
#
#   ok($page, "the browser page is the page named '$page_name'");
#   ok($pages{$page_name}, "the named page maps to a class name");
#   ok($page->isa($pages{$page_name}),
#      "the page is of expected class: " . ref $page);
# };

Then qr/ one tab called '(Person|Company)'/, sub {
  my $page = S->{ext_wsl}->page->body;
};

Given qr/a (.*+) with a (.+) ECA/, sub {
};

Then qr/ I see the '(.+)' Tab/, sub {
  my $tab = $1;
  ok(S->{ext_wsl}->page->find(".//*[\@role='tab' and text()='$tab']"),
    "the page has a tab named " . $tab)
};

#And qr/ click Save/, sub {
#};
#And qr/ click continue/, sub {
#};
#And qr/ enter a first name of 'Test'/, sub {
#};
#And qr/ enter a last name of 'Another test'/, sub {
#};
#And qr/ enter a name of of 'Testing, Inc'/, sub {
#};
#And qr/ enter a new account/, sub {
#};
#And qr/ enter a new address/, sub {
#};
#And qr/ enter a new note/, sub {
#};
#And qr/ enter a new phone number/, sub {
#};
#And qr/ one tab called 'Company'/, sub {
#};
#And qr/ select 'United States' as the country/, sub {
#};
#And qr/ select credit account/, sub {
#};
#And qr/ select entity/, sub {
#};

#And qr/ the Customer Number field is now filled in./, sub {
#};

#Then qr/ I see a listing with a customer with a name like 'Test'/, sub {
#};
#Then qr/ I see a listing with a customer with a name of 'Testing, Inc'/, sub {
#};
#Then qr/ I see a new line in the listing/, sub {
#};
#Then qr/ I see the /, sub {
#};
#Then qr/ I see the new address in the table list/, sub {
#};
#Then qr/ I see the new bank acount in the table list/, sub {
#};
#Then qr/ I see the new note in the note list/, sub {
#};
#Then qr/ I see the new phone number in the contact table list/, sub {
#};
#Then qr/ I see the search filter screen./, sub {
#};
#Then qr/ I see the vendor ECA record/, sub {
#};

#When qr/ I click 'Save' on the Credit Account tab/, sub {
#};
#When qr/ I click on the Addresses tab/, sub {
#};
#When qr/ I click on the Bank Accounts/, sub {
#};
#When qr/ I click on the Contact/, sub {
#};
#When qr/ I click on the Contacts\/Search menu/, sub {
#};
#When qr/ I click on the notes tab/, sub {
#};
#When qr/ I click the 'Test/, sub {
#};
#When qr/ I click the 'Testing, Inc'/, sub {
#};
#When qr/ I select custommer as the entity class/, sub {
#};
#With qr/ no credit accounts in the listing/, sub {
#};


1;
