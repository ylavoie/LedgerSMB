@one-db @weasel
Feature: correct operation of the menu and immediate linked pages
  As an end-user, I want to be able to navigate the menu and open
  the screens from the available links. If my authorizations
  don't allow a specific screen, I expect the links not to be in
  the menu.



Background:
  Given a standard test company


Scenario Outline: Navigate to menu and open screen
  Given a logged in admin
   When I navigate the menu and select the item at "<path>"
   Then I should see the <screen> screen
  Examples:
  | path                                              | screen                  |
  | AP > Add Transaction                              | AP transaction entry    |
  | AP > Debit Invoice                                | AP debit invoice entry  |
  | AP > Debit Note                                   | AP note entry           |
#N| AP > Import Batch                                 | Batch import            |
  | AP > Reports > AP Aging                           | Aging Report            |
  | AP > Reports > Outstanding                        | AP Outstanding          |
  | AP > Reports > Vendor History                     | Purchase History        |
# | AP > Search                                       | AP search               |
  | AP > Vendor Invoice                               | AP invoice entry        |
  | AP > Vouchers > AP Voucher                        | Create New Batch        |
#N| AP > Vouchers > Import AP Batch                   |                         |
  | AP > Vouchers > Invoice Vouchers                  | Create New Batch        |
# | AR > Add Return                                   | AR returns              |
  | AR > Add Transaction                              | AR transaction entry    |
  | AR > Credit Invoice                               | AR credit invoice entry |
  | AR > Credit Note                                  | AR note entry           |
  | AR > Import Batch                                 | Batch import            |
  | AR > Reports > AR Aging                           | Aging Report            |
  | AR > Reports > Customer History                   | Purchase History        |
  | AR > Reports > Outstanding                        | AR Outstanding          |
  | AR > Sales Invoice                                | AR invoice entry        |
# | AR > Search                                       | AR search               |
  | AR > Vouchers > AR Voucher                        | Create New Batch        |
# | AR > Vouchers > Import AR Batch                   |                         |
  | AR > Vouchers > Invoice Vouchers                  | Create New Batch        |
#N| Budgets > Add Budget                              |                         |
  | Budgets > Search                                  | Budget search           |
  | Cash > Payment                                    | Payments                |
  | Cash > Receipt                                    | Receipts                |
  | Cash > Reconciliation                             | New Reconciliation Report|
  | Cash > Reports > Payments                         | Search Payments         |
  | Cash > Reports > Receipts                         | Search Receipts         |
  | Cash > Reports > Reconciliation                   | Search Reconciliation Reports|
  | Cash > Transfer                                   | Add Cash Transfer Transaction|
  | Cash > Use AR Overpayment                         | Use Overpayment         |
  | Cash > Use Overpayment                            | Use Overpayment         |
  | Cash > Vouchers > Payments                        | Create New Batch        |
  | Cash > Vouchers > Receipts                        | Create New Batch        |
  | Cash > Vouchers > Reverse AR Overpay              | Create New Batch        |
  | Cash > Vouchers > Reverse Overpay                 | Create New Batch        |
  | Cash > Vouchers > Reverse Payment                 | Create New Batch        |
  | Cash > Vouchers > Reverse Receipts                | Create New Batch        |
#T| Contacts > Add Contact                            | contact creation        |
  | Contacts > Search                                 | Contact search          |
  | Fixed Assets > Asset Classes > Add Class          | Add Asset Class         |
  | Fixed Assets > Asset Classes > List Classes       | Search Asset Class      |
  | Fixed Assets > Assets > Add Assets                | Add Asset               |
  | Fixed Assets > Assets > Depreciate                | New Asset Report        |
  | Fixed Assets > Assets > Disposal                  | New Asset Report        |
#N| Fixed Assets > Assets > Import                    |                         |
  | Fixed Assets > Assets > Reports > Depreciation    | New Asset Report Search |
  | Fixed Assets > Assets > Reports > Disposal        | New Asset Report Search |
#N| Fixed Assets > Assets > Reports > Net Book Value  |                         |
#N| Fixed Assets > Assets > Search Assets             |                         |
#T| General Journal > Add Accounts                    |                         |
#N| General Journal > Chart of Accounts               |                         |
#N| General Journal > Import                          |                         |
#N| General Journal > Import Chart                    |                         |
  | General Journal > Journal Entry                   | Add General Ledger Transaction|
  | General Journal > Search and GL                   | GL search               |
#T| General Journal > Year End                        |                         |
  | Goods and Services > Add Assembly                 | assembly entry          |
  | Goods and Services > Add Group                    |                         |
  | Goods and Services > Add Overhead                 | overhead entry          |
  | Goods and Services > Add Part                     | part entry              |
  | Goods and Services > Add Pricegroup               |                         |
  | Goods and Services > Add Service                  | service entry           |
  | Goods and Services > Enter Inventory              |                         |
  | Goods and Services > Import Inventory             |                         |
  | Goods and Services > Reports > Inventory Activity |                         |
  | Goods and Services > Search                       |                         |
  | Goods and Services > Search Groups                |                         |
  | Goods and Services > Search Pricegroups           |                         |
  | Goods and Services > Stock Assembly               |                         |
  | Goods and Services > Translations > Description   |                         |
  | Goods and Services > Translations > Partsgroup    |                         |
# | HR > Employees > Add Employee                     |                         |
  | HR > Employees > Search                           | Employee search         |
  | Logout                                            |                         |
  | New Window                                        |                         |
  | Order Entry > Combine > Purchase Orders           | combine purchase order  |
  | Order Entry > Combine > Sales Orders              | combine sales order     |
  | Order Entry > Generate > Purchase Orders          | generate purchase order |
  | Order Entry > Generate > Sales Orders             | generate sales order    |
  | Order Entry > Purchase Order                      | Purchase order entry    |
  | Order Entry > Reports > Purchase Orders           | Purchase order search   |
  | Order Entry > Reports > Sales Orders              | Sales order search      |
  | Order Entry > Sales Order                         | Sales order entry       |
  | Preferences                                       |                         |
  | Quotations > Reports > Quotations                 | Quotation search        |
  | Quotations > Reports > RFQs                       | RFQ search              |
  | Quotations > RFQ                                  |                         |
  | Recurring Transactions                            |                         |
  | Reports > Balance Sheet                           |                         |
  | Reports > Income Statement                        |                         |
  | Reports > Inventory and COGS                      |                         |
  | Reports > Trial Balance                           |                         |
  | Shipping > Receive                                |                         |
  | Shipping > Ship                                   |                         |
  | Shipping > Transfer                               |                         |
  | System > Defaults                                 | system defaults         |
  | System > GIFI > Add GIFI                          |                         |
  | System > GIFI > Import GIFI                       |                         |
  | System > GIFI > List GIFI                         |                         |
  | System > HTML Templates > Invoicing               |                         |
  | System > HTML Templates > Ordering                |                         |
  | System > HTML Templates > Other                   |                         |
  | System > HTML Templates > Shipping                |                         |
  | System > Language > Add Language                  |                         |
  | System > Language > List Languages                |                         |
  | System > LaTeX Templates > Invoicing              |                         |
  | System > LaTeX Templates > Ordering               |                         |
  | System > LaTeX Templates > Other                  |                         |
  | System > LaTeX Templates > Shipping               |                         |
  | System > Reporting Units                          |                         |
  | System > Sequences                                |                         |
  | System > Sessions                                 |                         |
  | System > SIC > Add SIC                            |                         |
  | System > SIC > Import                             |                         |
  | System > SIC > List SIC                           |                         |
  | System > Taxes                                    | system taxes            |
  | System > Type of Business > Add Business          |                         |
  | System > Type of Business > List Businesses       |                         |
  | System > Warehouses > Add Warehouse               |                         |
  | System > Warehouses > List Warehouse              |                         |
  | Tax Forms > Add Tax Form                          |                         |
  | Tax Forms > List Tax Forms                        |                         |
  | Tax Forms > Reports                               |                         |
  | Timecards > Add Timecard                          |                         |
  | Timecards > Generate > Sales Orders               |                         |
  | Timecards > Import                                |                         |
  | Timecards > Search                                |                         |
  | Timecards > Translations > Description            |                         |
  | Transaction Approval > Batches                    | Search Unapproved Transactions|
  | Transaction Approval > Drafts                     | Search Unapproved Transactions|
  | Transaction Approval > Inventory                  | Search Inventory Entry  |
  | Transaction Approval > Reconciliation             | Search Reconciliation Reports|
  | Transaction Templates                             |                         |
