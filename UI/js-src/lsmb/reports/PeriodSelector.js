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
    return declare("lsmb/reports/PeriodSelector", [_WidgetBase, _Container], {
        channel: "",
        startup: function () {
            var self = this;

            this.inherited(arguments);
            this._byDates = registry.byId("comparison_by_dates");
            this._byPeriods = registry.byId("comparison_by_periods");
            this.own(
                on(this._byDates, "change", function (newvalue) {
                    if (newvalue) {
                        self._updateDisplay();
                        topic.publish(
                            self.channel,
                            "changed-period-type",
                            "by-dates"
                        );
                    }
                })
            );
            this.own(
                on(this._byPeriods, "change", function (newvalue) {
                    if (newvalue) {
                        self._updateDisplay();
                        topic.publish(
                            self.channel,
                            "changed-period-type",
                            "by-periods"
                        );
                    }
                })
            );
            this._updateDisplay();
        },
        _updateDisplay: function () {
            domStyle.set(
                dom.byId("date_dates_id"),
                "display",
                this._byDates.get("checked") ? "" : "none"
            );
            domStyle.set(
                dom.byId("date_period_id"),
                "display",
                this._byPeriods.get("checked") ? "" : "none"
            );
        }
    });
});
