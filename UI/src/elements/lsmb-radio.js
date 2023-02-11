/** @format */
/* eslint-disable class-methods-use-this, max-classes-per-file */

import { LsmbBaseChecked } from "@/elements/lsmb-base-checked";

const dojoRadioButton = require("dijit/form/RadioButton");

export class LsmbRadioButton extends LsmbBaseChecked {
    widgetWrapper = null;

    _widgetRoot() {
        if (this.widgetWrapper) {
            return this.widgetWrapper;
        }
        this.widgetWrapper = document.createElement("span");
        this.appendChild(this.widgetWrapper);

        return this.widgetWrapper;
    }

    _widgetClass() {
        return dojoRadioButton;
    }
}

customElements.define("lsmb-radio", LsmbRadioButton);