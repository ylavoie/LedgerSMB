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
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
     Then I see the "Person" tab
      And I should see a drop down "class" with these items:
        |     class      | value |
        | Vendor         |    1  |
        | Customer       |    2  |
        | Employee       |    3  |
        | Contact        |    4  |
        | Lead           |    5  |
        | Referral       |    6  |
        | Hot Lead       |    7  |
        | Cold Lead      |    8  |
        | Sub-contractor |    9  |
        | Robot          |   10  |
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Vendor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Vendor"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Customer
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Customer"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Employee
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Employee"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Contact
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Contact"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Lead"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Referral
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Referral"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Hot Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Cold Lead"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Cold Lead
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Sub-contractor"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Sub-contractor
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Sub-contractor"
      And click Generate Control Code
     Then error message should be thrown

Scenario: Create a New Company as Robot
    Given a logged in admin
     When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I should see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company"
     When I select the "Person" tab
      And select a class of "Robot"
      And click Generate Control Code
     Then error message should be thrown

# TODO
# Scenario: Look up person customer with all info filled out
#
# Scenario: Look up company vendor wit all info flled out
#
# Scenario: Add new Vendor ECA to Customer
#
# Scenario: Add new Customer ECA to Vendor
