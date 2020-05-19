/** @format */
/* eslint no-param-reassign:0 */

define([
   "dojo/parser",
   "dojo/query",
   "dojo/on",
   "dijit/registry",
   "dojo/_base/event",
   "dojo/hash",
   "dojo/topic",
   "dojo/dom-class",
   "dojo/mouse",
   "dojo/ready",
   "lsmb/html/credentials_html",
   "lsmb/html/login_html",
   "lsmb/html/payments2_html",
   /* Every reference */
   "dijit/Dialog",
   "dijit/form/Button",
   "dijit/form/CheckBox",
   "dijit/form/ComboBox",
   "dijit/form/CurrencyTextBox",
   "dijit/form/MultiSelect",
   "dijit/form/NumberSpinner",
   "dijit/form/NumberTextBox",
   "dijit/form/RadioButton",
   "dijit/form/Select",
   "dijit/form/Textarea",
   "dijit/form/TextBox",
   "dijit/form/ToggleButton",
   "dijit/form/ValidationTextBox",
   "dijit/layout/BorderContainer",
   "dijit/layout/ContentPane",
   "dijit/layout/TabContainer",
   "dijit/Tooltip",
   "lsmb/accounts/AccountSelector",
   "lsmb/DateTextBox",
   "lsmb/Form",
   "lsmb/Invoice",
   "lsmb/InvoiceLine",
   "lsmb/InvoiceLines",
   "lsmb/journal/fx_checkbox",
   "lsmb/layout/TableContainer",
   "lsmb/MainContentPane",
   "lsmb/menus/Tree",
   "lsmb/parts/PartDescription",
   "lsmb/parts/PartSelector",
   "lsmb/PrintButton",
   "lsmb/PublishCheckBox",
   "lsmb/PublishRadioButton",
   "lsmb/PublishSelect",
   "lsmb/PublishToggleButton",
   "lsmb/Reconciliation",
   "lsmb/ReconciliationLine",
   "lsmb/reports/ComparisonSelector",
   "lsmb/reports/PeriodSelector",
   "lsmb/ResizingTextarea",
   "lsmb/SetupLoginButton",
   "lsmb/SimpleForm",
   "lsmb/SubscribeCheckBox",
   "lsmb/SubscribeSelect",
   "lsmb/SubscribeShowHide",
   "lsmb/TemplateManager",
   "lsmb/users/ChangePassword"
], function (
   parser,
   query,
   on,
   registry,
   event,
   hash,
   topic,
   domClass,
   mouse,
   ready
) {
   ready(1, function () {
      parser.parse().then(function () {
         // delay the option of triggering load_link() until
         // the parser has run: before then, the maindiv widget
         // doesn't exist!
         var mainDiv = registry.byId("maindiv");

         // we need a centralized interceptClick function so
         // the hash part we generate to make it unique, really *is*
         // Without the hash part, clicking on a link twice won't
         // reload it. That's not too bad, except if a POST was sent
         // in the mean time; which causes the page content *not* to
         // correspond (directly) to the link in the browser location,
         // yet clicking on the link won't return the user to the -e.g.-
         // search page (that is -- without the hash part below)
         var c = 0;
         var interceptClick = function (dnode) {
            if (dnode.target || !dnode.href) {
               return;
            }

            var href = dnode.href + "#s";
            on(dnode, "click", function (e) {
               if (!e.ctrlKey && !e.shiftKey && mouse.isLeft(e)) {
                  event.stop(e);
                  c++;
                  hash(href + c.toString(16));
                  mainDiv.fade_main_div();
               }
            });
            var l = window.location;
            dnode.href =
               l.origin +
               l.pathname +
               l.search +
               "#" +
               dnode.href.substring(l.origin.length);
         };
         if (mainDiv != null) {
            mainDiv.interceptClick = interceptClick;
            if (window.location.hash) {
               mainDiv.load_link(hash());
            }
            topic.subscribe("/dojo/hashchange", function (_hash) {
               mainDiv.load_link(_hash);
            });
         }

         query("a.menu-terminus").forEach(interceptClick);

         ready(999, function () {
            query("#console-container").forEach(function (node) {
               domClass.add(node, "done-parsing");
            });
            query("body").forEach(function (node) {
               domClass.add(node, "done-parsing");
            });
         });
      });
   });
});
