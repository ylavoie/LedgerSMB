/** @format */
/* eslint no-param-reassign:0 */

require([
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
   "dojo/domReady!"
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

require([
   "dijit/Dialog",
   "dijit/ProgressBar",
   "dijit/Tooltip",
   "dijit/Tree",
   "dijit/_AttachMixin",
   "dijit/_Container",
   "dijit/_HasDropDown",
   "dijit/_TemplatedMixin",
   "dijit/_WidgetBase",
   "dijit/_WidgetsInTemplateMixin",
   "dijit/form/Button",
   "dijit/form/CheckBox",
   "dijit/form/ComboBox",
   "dijit/form/CurrencyTextBox",
   "dijit/form/DateTextBox",
   "dijit/form/FilteringSelect",
   "dijit/form/Form",
   "dijit/form/MultiSelect",
   "dijit/form/NumberSpinner",
   "dijit/form/NumberTextBox",
   "dijit/form/RadioButton",
   "dijit/form/Select",
   "dijit/form/TextBox",
   "dijit/form/ToggleButton",
   "dijit/form/ValidationTextBox",
   "dijit/form/_AutoCompleterMixin",
   "dijit/form/_ComboBoxMenu",
   "dijit/layout/BorderContainer",
   "dijit/layout/ContentPane",
   "dijit/layout/TabContainer",
   "dijit/layout/_LayoutWidget",
   "dijit/registry",
   "dijit/tree/ObjectStoreModel",
   "dojo/NodeList-dom",
   "dojo/NodeList-manipulate",
   "dojo/_base/array",
   "dojo/_base/declare",
   "dojo/_base/event",
   "dojo/_base/kernel",
   "dojo/_base/lang",
   "dojo/_base/window",
   "dojo/aspect",
   "dojo/cookie",
   "dojo/date/locale",
   "dojo/dom",
   "dojo/dom-attr",
   "dojo/dom-class",
   "dojo/dom-construct",
   "dojo/dom-form",
   "dojo/dom-prop",
   "dojo/dom-style",
   "dojo/domReady!",
   "dojo/has",
   "dojo/hash",
   "dojo/i18n",
   "dojo/io-query",
   "dojo/json",
   "dojo/keys",
   "dojo/mouse",
   "dojo/on",
   "dojo/parser",
   "dojo/promise/Promise",
   "dojo/promise/all",
   "dojo/query",
   "dojo/ready",
   "dojo/request",
   "dojo/request/handlers",
   "dojo/request/iframe",
   "dojo/request/util",
   "dojo/request/watch",
   "dojo/request/xhr",
   "dojo/store/Cache",
   "dojo/store/JsonRest",
   "dojo/store/Memory",
   "dojo/store/Observable",
   "dojo/topic",
   "lsmb/DateTextBox",
   "lsmb/FilteringSelect",
   "lsmb/Form",
   "lsmb/Invoice",
   "lsmb/InvoiceLine",
   "lsmb/InvoiceLines",
   "lsmb/MainContentPane",
   "lsmb/MaximizeMinimize",
   "lsmb/PrintButton",
   "lsmb/PublishCheckBox",
   "lsmb/PublishNumberTextBox",
   "lsmb/PublishRadioButton",
   "lsmb/PublishSelect",
   "lsmb/PublishToggleButton",
   "lsmb/Reconciliation",
   "lsmb/ReconciliationLine",
   "lsmb/ResizingTextarea",
   "lsmb/SetupLoginButton",
   "lsmb/SimpleForm",
   "lsmb/SubscribeCheckBox",
   "lsmb/SubscribeNumberTextBox",
   "lsmb/SubscribeRadioButton",
   "lsmb/SubscribeSelect",
   "lsmb/SubscribeShowHide",
   "lsmb/SubscribeToggleButton",
   "lsmb/TemplateManager",
   "lsmb/accounts/AccountRestStore",
   "lsmb/accounts/AccountSelector",
   "lsmb/iframe",
   "lsmb/journal/fx_checkbox",
   "lsmb/layout/TableContainer",
   "lsmb/menus/Tree",
   "lsmb/parts/PartDescription",
   "lsmb/parts/PartRestStore",
   "lsmb/parts/PartSelector",
   "lsmb/payments/PostPrintButton",
   "lsmb/reports/ComparisonSelector",
   "lsmb/reports/PeriodSelector",
   "lsmb/users/ChangePassword"
]);
