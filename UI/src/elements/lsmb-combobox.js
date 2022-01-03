/** @format */
/* eslint-disable class-methods-use-this, max-classes-per-file */

import { LsmbBaseInput } from "./lsmb-base-input";

const dojoComboBox = require("dijit/form/ComboBox");
const storeMemory = require("dojo/store/Memory");

export class LsmbComboBox extends LsmbBaseInput {
    _stdProps() {
        let store = new storeMemory({ data: this._options });
        return {
            type: "select",
            store: store,
            searchAttr: "text",
            value: this.default_blank || this.required ? "" : " "
        };
    }

    _valueAttrs() {
        return [...super._valueAttrs(), "maxHeight", "options"];
    }

    _widgetClass() {
        return dojoComboBox;
    }

    set options(newValue) {
        this._options = newValue;
    }
}

customElements.define("lsmb-combobox", LsmbComboBox);
