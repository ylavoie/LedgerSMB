@one-db @weasel
Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

Scenario: Add new bank account to person
   Given a person with a customer ECA
    When I click on the Bank Accounts
     And enter a new account
     And click Save
    Then I see the new bank acount in the table list

Scenario: Add New Phone number to Person
   Given a person with a customer ECA
    When I click on the Contact
     And enter a new phone number
     And click Save
    Then I see the new phone number in the contact table list

# TODO
# Scenario: Look up person customer with all info filled out
#
# Scenario: Look up company vendor wit all info flled out
#
# Scenario: Add new Vendor ECA to Customer
#
# Scenario: Add new Customer ECA to Vendor
