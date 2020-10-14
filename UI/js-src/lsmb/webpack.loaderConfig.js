/*
 * (C) Copyright IBM Corp. 2012, 2016 All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @format
 */
/* global dojoConfig */
/* eslint no-global-assign:0 */

const _dojoBuilt = "[% DOJO_BUILT %]";

// eslint-disable-next-line no-unused-vars
function getConfig(env) {
    // env is set by the "buildEnvironment" and/or "environment" plugin options
    // (see webpack.config.js),
    // or by the code at the end of this file if using without webpack
    // The next statement must work fow webpack & runtime with Perl TT
    var dojoConfig = {
        baseUrl: "./",
        packages: [
            {
                name: "lsmb", // the name of the package
                location: "js-src/lsmb" // the directory path where it resides
            }
        ],
        paths: {
            dojo: env.dojoRoot + "/dojo",
            dijit: env.dojoRoot + "/dijit",
            themes: env.dojoRoot + "/dijit/themes",
            css: "js/css",
            ...(env.paths || {})
        },
        async: true, // Defines if Dojo core should be loaded asynchronously
        deps: [
            "dojo/parser",
            // _WidgetsInTemplateMixin doesn't support autoloading,
            // thus the list below for dojo_built=0
            // deps is ignored by the dojo-webpack-plugin
            "lsmb/DateTextBox",
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
            "lsmb/SetupLoginButton",
            "lsmb/SubscribeCheckBox",
            "lsmb/SubscribeNumberTextBox",
            "lsmb/SubscribeSelect",
            "lsmb/SubscribeShowHide"
        ],
        parseOnLoad: true,
        // blankGif: env.dojoRoot + "/dojo/resources/blank.gif",
        has: {
            "dojo-publish-privates'": 1, // Enables the exposure of some internal information for the loader.
            "dojo-undef-api'": 0 // Removes support for module unloading
        },
        locale: "[% USER.language.lower().replace('_','-') %]",
        mode:
            _dojoBuilt !== "0"
                ? "<%= htmlWebpackPlugin.options.mode %>"
                : "development"
    };
    return dojoConfig;
}
// For Webpack, export the config.
// This is needed both at build time and on the client at runtime
if (typeof module !== "undefined") {
    module.exports = getConfig;
}
