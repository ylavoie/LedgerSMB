define("lsmb/Reconciliation",
       ["dojo/_base/declare",
        "dojo/topic",
        "dojo/query",
        "lsmb/Form",
        "dijit/registry",
        "dijit/_Container",
        "dojo/NodeList-dom",     // To load extensions in query
        "dojo/domReady!"],
       function(declare, topic, query, Form, Registry, _Container) {
           return declare("lsmb/Reconciliation", [Form, _Container], {
               update: function(targetValue, prefix) {
                   query(prefix + " tbody tr.record").style("display", targetValue ? "" : "none");
               },
               updateSolution: function(j) {
                   var s = "[name^='solution_"+j+"_']"; 
                   query(s).forEach(function(node) {
                       var res = node.id.split('-');
                       var cb = Registry.byId("cleared-"+res[2]);
                       cb.set("checked",node.innerText.length > 0) ;
                   });
               },
               postCreate: function() {
                   var self = this;
                   this.inherited(arguments);
                   topic.subscribe("ui/reconciliation/report/b_unapproved_transactions",
                        function(targetValue) {
                            self.update(targetValue,"#unapproved-transactions");
                        });
                   topic.subscribe("ui/reconciliation/report/b_unapproved_reconciliations",
                        function(targetValue) {
                            self.update(targetValue,"#unapproved-reconciliations");
                        });
                   topic.subscribe("ui/reconciliation/report/b_cleared_without_report",
                        function(targetValue) {
                            self.update(targetValue,"#cleared-without-report");
                        });
                   topic.subscribe("ui/reconciliation/report/b_cleared_table",
                        function(targetValue) {
                            self.update(targetValue,"#cleared-table");
                        });
                   topic.subscribe("ui/reconciliation/report/b_mismatch_table",
                        function(targetValue) {
                            self.update(targetValue,"#mismatch-table");
                        });
                   topic.subscribe("ui/reconciliation/report/b_outstanding_table",
                        function(targetValue) {
                            self.update(targetValue,"#outstanding-table");
                        });
                   topic.subscribe("ui/reconciliation/report/solution-selected",
                        function(targetValue) {
                            self.updateSolution(targetValue);
                        });
               }
           });
       });
