@weasel
Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

Scenario: Create a New Company as Vendor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Company" tab
      And I select "Vendor" from the drop down "Class"
      And I enter these values:
        | label   | value         |
        | Name    | Another test  |
        | Country | United States |
      And I press "Generate Control Code"
     Then I should get a valid Control Code
      And I press "Save"
     Then I see the "Credit Account" Tab
      And no credit accounts in the listing
     When I click "Save" on the Credit Account tab
     Then I see a new line in the listing
      And the Customer Number field is now filled in.

Scenario: Add new note to company
   Given a company with a vendor ECA
    When I click on the notes tab
     And enter a new note
     And select credit account
     And click Save
    Then I see the new note in the note list

Scenario: Look Up Existing Company as Vendor
     When I click on the Contacts/Search menu
     Then I see the search filter screen.
     When I select custommer as the entity class
      And click continue
     Then I see a listing with a customer with a name of "Testing, Inc"
     When I click the "Testing, Inc"
     Then I see the vendor ECA record
