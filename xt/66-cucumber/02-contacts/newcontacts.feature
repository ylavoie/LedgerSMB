Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

Scenario: Create a New Person as Customer
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And enter a first name of "Test"
      And enter a last name of "Another test"
      And select "United States" as the country
      And click Save
     Then I see the "Credit Account" Tab
      And no credit accounts in the listing
     When I click "Save" on the Credit Account tab
     Then I see a new line in the listing
      And the Customer Number field is now filled in.

Scenario: Create a New Company as Vendor
  Given a logged in admin
    When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Company" tab
      And enter a name of of "Testing, Inc"
      And select "United States" as the country
      And click Save
     Then I see the "Credit Account" Tab
      And no credit accounts in the listing
     When I click "Save" on the Credit Account tab
     Then I see a new line in the listing
      And the Customer Number field is now filled in.

Scenario: Look Up Existing Person as Customer
     When I click on the Contacts/Search menu
     Then I see the search filter screen.
     When I select custommer as the entity class
      And click continue
     Then I see a listing with a customer with a name like "Test"
     When I click the "Test"
     Then I see the customer ECA record

Scenario: Look Up Existing Company as Vendor
     When I click on the Contacts/Search menu
     Then I see the search filter screen.
     When I select custommer as the entity class
      And click continue
     Then I see a listing with a customer with a name of "Testing, Inc"
     When I click the "Testing, Inc"
     Then I see the vendor ECA record

Scenario: Add Address to Customer ECA
   Given a person with a customer ECA
    When I click on the Addresses tab
     And enter a new address
     And select credit account
     And click Save
    Then I see the new address in the table list

Scenario: Add Address to Customer Entity
   Given a person with a customer ECA
    When I click on the Addresses tab
     And enter a new address
     And select entity
     And click Save
    Then I see the new address in the table list

Scenario: Add new note to company
   Given a company with a vendor ECA
    When I click on the notes tab
     And enter a new note
     And select credit account
     And click Save
    Then I see the new note in the note list


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
