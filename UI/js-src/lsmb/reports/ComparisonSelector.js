define(["dojo/_base/declare",
        "dojo/on",
        "dojo/dom",
        "dojo/dom-style",
        "dojo/topic",
        "dijit/registry",
        "dijit/_WidgetBase",
        "dijit/_Container"
       ],
       function(declare, on, dom, style, topic, registry,
                _WidgetBase, _Container) {
           return declare("lsmb/reports/ComparisonSelector",
                          [_WidgetBase, _Container], {
               channel: '',
               mode: "by-dates",
               postCreate: function() {
                   var self = this;
                   this.inherited(arguments);
                   this.own(
                       topic.subscribe(this.channel,
                          function(action, value) {
                              var display = "";

                              if (action === "changed-period-type") {
                                  self.mode = value;

                                  if (value === "by-dates") {
                                      display = self._comparison_periods
                                          .get("value");
                                  }
                              }
                              self._update_display(display);
                          })
                   );
               },
               startup: function() {
                   var self = this;

                   this.inherited(arguments);
                   this._comparison_periods =
                       registry.byId("comparison-periods");
                   this.own(
                       on(this._comparison_periods, "change",
                          function(newvalue) {
                              self._update_display(self._comparison_periods
                                                   .get("value"));
                          }));
                   this._update_display('');
               },
               _set_required: function(domNode,value) {
                   /*
                   var dn = dom.byId(domNode);
                   var dr = registry.findWidgets(dn);
                   for ( var i = 0 ; i < dr.count ; i++ )
                      dr[i].set("required", value);
                  */
               },
               _update_display: function(count) {
                   var self = this;

                   if (count === "" || this.mode === "by-periods") {
                       style.set(dom.byId("comparison_dates"),
                                 "display", "none");
                       self._set_required("comparison_dates", false);
                       self._set_required("comparison-periods", true);
                       return;
                   }
                   else {
                       count = parseInt(count);
                       if (isNaN(count)) return; // invalid input

                       style.set(dom.byId("comparison_dates"), "display", "");
                       self._set_required("comparison_dates", true);
                       self._set_required("comparison-periods", false);
                       for (var i = 1; i <= 9; i++) {
                           style.set(dom.byId("comparison_dates_" + i),
                                     "display", (i <= count) ? "" : "none");
                       }
                   }
               }
           });
       });
