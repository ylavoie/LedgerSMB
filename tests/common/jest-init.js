/** @format */
/* eslint-disable vue/component-definition-name-casing */
/* eslint-disable vue/require-prop-types, vue/one-component-per-file */
/* eslint-disable global-require */

import "whatwg-fetch";

Object.defineProperty(window, "lsmbConfig", {
    writable: true,
    value: {
        version: "1.10",
        language: "en"
    }
});

// window.location = new URL('http://lsmb');

import "./mocks/lsmb_components";
