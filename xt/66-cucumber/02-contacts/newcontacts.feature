Feature: This application tests general components of contact management
including new customers, vendors, leads and so forth.

Background:
   Given a standard test company
     And a US/General Chart of Accounts
 # should have been : And a logged in accounting user

Scenario: Create a New Company as Vendor
  Given a logged in admin
    When I navigate the menu and select the item at "Contacts > Add Contact"
     Then I see the Add Contact screen
      And one tab called "Person"
      And one tab called "Company".

# TODO
# Scenario: Look up person customer with all info filled out
#
# Scenario: Look up company vendor with all info filled out
#
