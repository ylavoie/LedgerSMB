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

// eslint-disable-next-line no-unused-vars
function getConfig(env) {
    // env is set by the 'buildEnvironment' and/or 'environment' plugin options (see webpack.config.js),
    // or by the code at the end of this file if using without webpack
    var dojoConfig = {
        packages: [
            // An array of objects which provide the package name and location
            {
                name: "dojo",
                location: env.dojoRoot + "/dojo"
            },
            {
                name: "dijit",
                location: env.dojoRoot + "/dijit"
            },
            {
                name: "lsmb", // the name of the package
                location: "js-src/lsmb" // the path to the directory where the package resides
            }
        ],

		paths: {
			js: "js-src",
			// theme: "theme",
			// With the webpack build, the css loader plugin is replaced by a webpack loader
			// via webpack.config.js, so the following are used only by the unpacked app.
			css: "css",
			// lesspp is used by the css loader plugin when loading LESS modules
			// lesspp: "//cdnjs.cloudflare.com/ajax/libs/less.js/1.7.3/less.min",
		},

        async: true, // Defines if Dojo core should be loaded asynchronously
        blankGif: env.dojoRoot + "/dojo/resources/blank.gif",
        deps: ["lsmb/main"], // An array of resource paths which should load immediately once Dojo has loaded:

        has: {
            "dojo-config-api": 1, // Ensures that the build is configurable
            "dojo-has-api": 1, // Ensures the has feature detection API is available.
            'dojo-trace-api':                 1, // Disables the tracing of module loading.
            'host-browser':                   1, // Ensures the code is built to run on a browser platform
            'dojo-config-require':            1, // Enables configuration via the require().
            'dojo-v1x-i18n-Api':              1, // Enables support for v1.x i18n loading (required for Dijit)
            'dojo-dom-ready-api':             1, // Ensures that the DOM ready API is available
            'extend-dojo':                    1, // Ensures pre-Dojo 2.0 behavior is maintained
            'dojo-guarantee-console':         1, // Ensures that the console is available in browsers that don't have it available (e.g. IE6)
            'dojo-inject-api':                1, // Ensures the cross domain loading of modules is supported
            'dojo-loader':                    1, // Ensures the loader is available
            'config-deferredInstrumentation': 1, // Disables automatic loading of code that reports un-handled rejected promises
            'config-dojo-loader-catches':     1, // Disables some of the error handling when loading modules.
            'config-tlmSiblingOfDojo':        0, // Disables non-standard module resolution code.
            'dojo-amd-factory-scan':          1, // Assumes that all modules are AMD
            'dojo-combo-api':                 1, // Disables some of the legacy loader API
            'dojo-debug-messages':            1, // Disables some diagnostic information
            'dojo-log-api':                   1, // Disables the logging code of the loader
            'dojo-modulePaths':               1, // Removes some legacy API related to loading modules
            'dojo-moduleUrl':                 1, // Removes some legacy API related to loading modules
            'dojo-publish-privates':          1, // Disables the exposure of some internal information for the loader.
            'dojo-requirejs-api':             1, // Disables support for RequireJS
            'dojo-sniff':                     0, // Enables scanning of data-dojo-config and djConfig in the dojo.js script tag
            'dojo-sync-loader':               0, // Disables the legacy loader
            'dojo-test-sniff':                0, // Disables some features for testing purposes
            'dojo-timeout-api':               1, // Disables code dealing with modules that don't load
            'dojo-undef-api':                 1 , // Removes support for module unloading
        },

        fixupUrl: function (url) {
            // Load the uncompressed versions of dojo/dijit/dojox javascript files when using the dojo loader.
            // When using a webpack build, the dojo loader is not used for loading javascript files so this
            // property has no effect.  This is only needed when we're loading Dojo from a CDN.
            // In a normal development environment, Dojo would be installed locally and this wouldn't
            // be needed.
            // return /\/(dojo|dijit|dojox)\/.*\.js$/.test(url)
            //     ? url + ".uncompressed.js"
            //     : url;
            return url;
        }
    };
    return dojoConfig;
}
// For Webpack, export the config.  This is needed both at build time and on the client at runtime
// for the packed application.
if (typeof module !== "undefined") {
    module.exports = getConfig;
} else {
    // No webpack.  This script was loaded by page via script tag, so load Dojo from CDN
    getConfig({ dojoRoot: "//download.dojotoolkit.org/release-1.16.3/dojo-release-1.16.3" });
    //getConfig({ dojoRoot: "../node_modules" });
}
