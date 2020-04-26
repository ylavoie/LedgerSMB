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
 */
function getConfig(env) {
    // env is set by the 'buildEnvironment' and/or 'environment' plugin options (see webpack.config.js),
    // or by the code at the end of this file if using without webpack
    dojoConfig = {
        baseUrl: '.',           // The base URL prepended to a module identifier when converting it to a path or URL
        packages: [             // An array of objects which provide the package name and location
			{
				name: 'dojo',
				location: env.dojoRoot + '/dojo',
			},
			{
				name: 'dijit',
				location: env.dojoRoot + '/dijit',
			},
			{
				name: 'lsmb',                       // the name of the package
				location: './js-src/lsmb',           // the path to the directory where the package resides
                main: 'main'                        // the module identifier implied when a module identifier
                                                    // that is equivalent to just the package name is given;
                                                    // defaults to 'main'
			}
		],

        // Allows you to map paths in module identifiers to different paths:
        //map: {
            //dijit16: {
            //    dojo: "dojo16"
            //}
        //},

        paths: {                // a map of module id fragments to file paths:
            js: "js",
            //theme: "theme",
            // With the webpack build, the css loader plugin is replaced by a webpack loader
            // via webpack.config.js, so the following are used only by the unpacked app.
            //css: "//chuckdumont.github.io/dojo-css-plugin/1.0.0/css",
            // lesspp is used by the css loader plugin when loading LESS modules
            //lesspp: "//cdnjs.cloudflare.com/ajax/libs/less.js/1.7.3/less.min",
        },

        async: true,            // Defines if Dojo core should be loaded asynchronously
        deps: ["lsmb/main"],    // An array of resource paths which should load immediately once Dojo has loaded:

        has: {
            'dojo-config-api':                1, // Ensures that the build is configurable
            /*'config-deferredInstrumentation': 0, // Disables automatic loading of code that reports un-handled rejected promises
            'config-dojo-loader-catches':     0, // Disables some of the error handling when loading modules.
            'config-tlmSiblingOfDojo':        0, // Disables non-standard module resolution code.
            'dojo-amd-factory-scan':          0, // Assumes that all modules are AMD
            'dojo-combo-api':                 0, // Disables some of the legacy loader API
            'dojo-config-api':                1, // Ensures that the build is configurable
            'dojo-config-require':            0, // Disables configuration via the require().
            'dojo-debug-messages':            0, // Disables some diagnostic information
            'dojo-dom-ready-api':             1, // Ensures that the DOM ready API is available
            'dojo-firebug':                   0, // Disables Firebug Lite for browsers that don't have a developer console (e.g. IE6)
            'dojo-guarantee-console':         1, // Ensures that the console is available in browsers that don't have it available (e.g. IE6)
            'dojo-has-api':                   1, // Ensures the has feature detection API is available.
            'dojo-inject-api':                1, // Ensures the cross domain loading of modules is supported
            'dojo-loader':                    1, // Ensures the loader is available
            'dojo-log-api':                   0, // Disables the logging code of the loader
            'dojo-modulePaths':               0, // Removes some legacy API related to loading modules
            'dojo-moduleUrl':                 0, // Removes some legacy API related to loading modules
            'dojo-publish-privates':          0, // Disables the exposure of some internal information for the loader.
            'dojo-requirejs-api':             0, // Disables support for RequireJS
// sniff crashes webpack
//				'dojo-sniff':                     1, // Enables scanning of data-dojo-config and djConfig in the dojo.js script tag
            'dojo-sync-loader':               0, // Disables the legacy loader
            'dojo-test-sniff':                0, // Disables some features for testing purposes
            'dojo-timeout-api':               0, // Disables code dealing with modules that don't load
            'dojo-trace-api':                 0, // Disables the tracing of module loading.
            'dojo-undef-api':                 0, // Removes support for module unloading
            'dojo-v1x-i18n-Api':              1, // Enables support for v1.x i18n loading (required for Dijit)
// dom crashes wecpack
//				'dom':                            1, // Ensures the DOM code is available
            'host-browser':                   1, // Ensures the code is built to run on a browser platform
            'extend-dojo':                    1, // Ensures pre-Dojo 2.0 behavior is maintained
        */},
    };
    return dojoConfig;
}
// For Webpack, export the config.  This is needed both at build time and on the client at runtime
// for the packed application.
if (typeof module !== 'undefined' && module) {
    module.exports = getConfig;
} else {
    // No webpack.  This script was loaded by page via script tag, so load Dojo from CDN
    getConfig({dojoRoot: '//ajax.googleapis.com/ajax/libs/dojo/1.16.0'});
}