Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

Scenario: Look Up Existing Company as Vendor
     When I click on the Contacts/Search menu
     Then I see the search filter screen.
     When I select custommer as the entity class
      And click continue
     Then I see a listing with a customer with a name of "Testing, Inc"
     When I click the "Testing, Inc"
     Then I see the vendor ECA record

