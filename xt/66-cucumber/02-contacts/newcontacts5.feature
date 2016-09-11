Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

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
