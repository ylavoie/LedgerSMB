/** @format */
/* eslint-disable vue/component-definition-name-casing */
/* eslint-disable vue/require-prop-types, vue/one-component-per-file */
/* eslint-disable global-require */

import { config } from "@vue/test-utils";
import { defineComponent } from "vue";

Object.defineProperty(window, "lsmbConfig", {
    writable: true,
    value: {
        version: "1.10",
        language: "en"
    }
});
Object.defineProperty(window, "location", {
    writable: true,
    value: { href: null }
});

const lsmbPassword = defineComponent({
    name: "lsmb-password",
    props: [
        "type",
        "name",
        "size",
        "id",
        "title",
        "tabindex",
        "value",
        "autocomplete"
    ],
    template: `
    <div>
      <label :for=id>{{ title }}</label>
      <input :type=type :id=id :name=name :size=size :tabindex=tabindex :autocomplete=autocomplete :value=value>
    </div>
  `
});

const lsmbText = defineComponent({
    name: "lsmb-text",
    props: [
        "type",
        "name",
        "size",
        "id",
        "title",
        "tabindex",
        "value",
        "autocomplete"
    ],
    template: `
    <div>
      <label :for=id>{{ title }}</label>
      <input :type=type :id=id :name=name :size=size :tabindex=tabindex :autocomplete=autocomplete :value=value>
    </div>
    `
});

const lsmbButton = defineComponent({
    name: "lsmb-button",
    template: `<button><slot /></button>`
});

const lsmbDate = defineComponent({
    name: "lsmb-date",
    props: ["id", "title", "name", "size", "required", "change"],
    template: `
      <div>
        <label>{{ title }}</label>
        <span :id=id :name=name :size=size :required=required @change=change></span>
      </div>
    `
});

const lsmbFile = defineComponent({
    name: "lsmb-file",
    props: ["id", "label", "accept", "disabled", "required", "change"],
    template: `
    <div>
      <label>{{ label }}</label>
      <span>
        <input type=file :id=id :name=name :accept=accept :size=size :required=required @change=change>
      </span>
    </div>
  `
});

config.global.stubs = {
    lsmbButton,
    lsmbPassword,
    lsmbText,
    lsmbDate,
    lsmbFile
};
