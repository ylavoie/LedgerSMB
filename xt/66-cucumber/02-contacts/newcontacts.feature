@weasel
Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
# should have been : And a logged in accounting user

Scenario: Validate the classes in the Person tab
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
     Then I see the "Person" tab
      And I should see a drop down "Class" with these items:
        | class          | value |
        | Vendor         | 1     |
        | Customer       | 2     |
        | Employee       | 3     |
        | Contact        | 4     |
        | Lead           | 5     |
        | Referral       | 6     |
        | Hot Lead       | 7     |
        | Cold Lead      | 8     |
        | Sub-contractor | 9     |
        | Robot          | 10    |
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Vendor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Vendor" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Customer
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Customer" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Employee
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Employee" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Contact
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Contact" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Lead" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Referral
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Referral" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Hot Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Cold Lead" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Cold Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Sub-contractor" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Sub-contractor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Sub-contractor" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

Scenario: Create a New Person as Robot
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
     When I select the "Person" tab
      And I select "Robot" from the drop down "Class"
     When I press "Generate Control Code"
     Then an error message should be thrown

# TODO
# Scenario: Look up person customer with all info filled out
#
# Scenario: Look up company vendor wit all info flled out
#
# Scenario: Add new Vendor ECA to Customer
#
# Scenario: Add new Customer ECA to Vendor
