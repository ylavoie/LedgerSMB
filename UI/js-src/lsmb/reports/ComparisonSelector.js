/** @format */

define([
    "dojo/_base/declare",
    "dojo/on",
    "dojo/dom",
    "dojo/dom-style",
    "dojo/topic",
    "dijit/registry",
    "dijit/_WidgetBase",
    "dijit/_Container"
], function (
    declare,
    on,
    dom,
    domStyle,
    topic,
    registry,
    _WidgetBase,
    _Container
) {
    return declare(
        "lsmb/reports/ComparisonSelector",
        [_WidgetBase, _Container],
        {
            channel: "",
            mode: "by-dates",
            postCreate: function () {
                var self = this;
                this.inherited(arguments);
                this.own(
                    topic.subscribe(this.channel, function (action, value) {
                        var display = "";

                        if (action === "changed-period-type") {
                            self.mode = value;

                            if (value === "by-dates") {
                                display = this._comparisonPeriods.get("value");
                            }
                        }
                        self._updateDisplay(display);
                    })
                );
            },
            startup: function () {
                var self = this;

                this.inherited(arguments);
                this._comparisonPeriods = registry.byId("comparison-periods");
                this.own(
                    on(
                        this._comparisonPeriods,
                        "change",
                        function (/* newvalue */) {
                            self._updateDisplay(
                                self._comparisonPeriods.get("value")
                            );
                        }
                    )
                );
                this._updateDisplay("");
            },
            _updateDisplay: function (count) {
                if (count === "" || this.mode === "by-periods") {
                    domStyle.set(
                        dom.byId("comparison_dates"),
                        "display",
                        "none"
                    );
                    return;
                }
                var _count = parseInt(count, 10);
                if (Number.isNaN(_count)) {
                    return;
                } // invalid input

                domStyle.set(dom.byId("comparison_dates"), "display", "");
                for (var i = 1; i <= 13; i++) {
                    domStyle.set(
                        dom.byId("comparison_dates_" + i),
                        "display",
                        i <= _count ? "" : "none"
                    );
                }
            }
        }
    );
});
