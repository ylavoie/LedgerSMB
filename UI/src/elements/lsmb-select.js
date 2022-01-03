/** @format */
/* eslint-disable class-methods-use-this, max-classes-per-file */

import { LsmbBaseInput } from "./lsmb-base-input";

const dojoSelectBox = require("dijit/form/Select");

export class LsmbSelect extends LsmbBaseInput {
    _stdProps() {
        let options = this._options;
        if (this.default_blank) {
            options.unshift({
                label: "",
                value: this.required ? "" : "_!lsmb!empty!_"
            });
        }
        return {
            type: "select",
            options: options
        };
    }

    _valueAttrs() {
        return [...super._valueAttrs(), "maxHeight", "options"];
    }

    _widgetClass() {
        return dojoSelectBox;
    }

    set options(newValue) {
        this._options = newValue;
    }
}

customElements.define("lsmb-select", LsmbSelect);
