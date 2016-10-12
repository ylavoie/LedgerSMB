@wip @weasel
Feature: Cash Reports: Receipts, Payments, Reconciliations
  As a LedgerSMB user, I want to be able to create reports on
  Receipts, Payments, Reconciliations

Scenario: Creation of a Cash Report for Reconciliations
   Given a standard test company
     And a logged in accounting user
   When I navigate the menu and select the item at "Cash > Reports > Reconciliation"
   Then I should see the "Search Reconciliation Reports"
