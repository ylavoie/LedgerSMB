@weasel
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
     When I select the "Person" tab
      And I select "Customer" from the drop down "Class"
      And I enter these values:
        |     label      | value         |
        | Salutation     | Mr.           |
        | Given Name     | Test          |
        | Surname        | Another test  |
        | Country        | United States |
        | Personal ID    | 123456        |
        | Birthdate      | 1963-01-02    |
      And I press "Generate Control Code"
     Then I should get a valid Control Code
     When I press "Save"
     Then I see the "Credit Accounts" tab
      And no credit accounts in the listing
     When I press "Save New" on the Credit Account tab
     Then I see a new line in the listing
      And the Customer Number field is now filled in.

Scenario: Create a New Person as Vendor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Vendor" from the drop down "Class"
      And I enter these values:
        |     label      | value         |
        | Salutation     | Mr.           |
        | Given Name     | Test          |
        | Surname        | Another test  |
        | Country        | United States |
        | Personal ID    | 123456        |
        | Birthdate      | 1963-01-02    |
      And I press "Generate Control Code"
     Then I should get a valid Control Code
     When I press "Save"
     Then I see the "Credit Accounts" tab
      And no credit accounts in the listing
     When I press "Save New" on the Credit Account tab
     Then I see a new line in the listing
      And the Vendor Number field is now filled in.

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

Scenario: Look Up Existing Person as Customer
     When I navigate the menu and select the item at "Contacts > Search"
     Then I see the Contact search screen.
      And I select "Vendor" from the drop down "Entity Class"
      And I press "Search"
     Then I see a listing with a customer with a name like "Test"
     When I press the "Test"
     Then I see the customer ECA record
