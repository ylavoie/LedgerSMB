@weasel
Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

#Background:
#   Given a standard test company
#     And a US/General Chart of Accounts
## should have been : And a logged in accounting user

Scenario: Create a New Person as Customer
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Customer"
      And enter a salutation of "Mr."
      And enter a given name of "Test"
      And enter a surname of "Another test"
      And select "United States" as the country
      And enter a personal id of 123456
      And enter a birthdate of "1963-01-02"
      And click Generate Control Code
      And click Save
     Then I see the "Credit Accounts" Tab
      And no credit accounts in the listing
     When I click "Save New" on the Credit Account tab
     Then I see a new line in the listing
      And the Customer Number field is now filled in.

Scenario: Create a New Person as Vendor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Vendor"
      And enter a salutation of "Mr."
      And enter a given name of "Test"
      And enter a surname of "Another test"
      And select "United States" as the country
      And enter a personal id of 123456
      And enter a birthdate of "1963-01-02"
      And click Generate Control Code
      And click Save
     Then I see the "Credit Accounts" Tab
      And no credit accounts in the listing
     When I click "Save New" on the Credit Account tab
     Then I see a new line in the listing
      And the Vendor Number field is now filled in.
