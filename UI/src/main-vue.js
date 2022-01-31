/** @format */
/* eslint-disable no-console, import/no-unresolved */

import { createApp } from "vue";
import router from "./router";
import i18n, { detectLanguage, loadLocaleMessages } from "./i18n";
import LoginPage from "./components/LoginPage.vue";
import SetupPage from "./components/SetupPage.vue";

const registry = require("dijit/registry");
const dojoParser = require("dojo/parser");

let app;
let appName;
let lsmbDirective = {
    beforeMount(el, binding) {
        let handler = (event) => {
            /* eslint-disable no-param-reassign */
            binding.instance[binding.arg] = event.target.value;
        };
        el.addEventListener("input", handler);
        el.addEventListener("change", handler);
    }
};

if (document.getElementById("main")) {
    app = createApp({
        beforeCreate() {
            // Load the user desired language if not default
            loadLocaleMessages(detectLanguage());
        },
        mounted() {
            let m = document.getElementById("main");

            this.$nextTick(() => {
                dojoParser.parse(m).then(() => {
                    let r = registry.byId("top_menu");
                    if (r) {
                        // Setup doesn't have top_menu
                        r.load_link = (url) => this.$router.push(url);
                    }
                    document.body.setAttribute("data-lsmb-done", "true");
                });
            });
            window.__lsmbLoadLink = (url) => this.$router.push(url);
        },
        beforeUpdate() {
            document.body.removeAttribute("data-lsmb-done");
        },
        updated() {
            document.body.setAttribute("data-lsmb-done", "true");
        }
    }).use(router);

    appName = "#main";
} else if (document.getElementById("login")) {
    app = createApp(LoginPage);
    appName = "#login";
} else if (document.getElementById("setup")) {
    app = createApp(SetupPage);
    appName = "#setup";
} else {
    /* In case we're running a "setup.pl" page */
    dojoParser.parse(document.body).then(() => {
        const l = document.getElementById("loading");
        if (l) {
            l.style.display = "none";
        }
        document.body.setAttribute("data-lsmb-done", "true");
    });
}
if (app) {
    app.config.compilerOptions.isCustomElement = (tag) =>
        tag.startsWith("lsmb-");
    app.directive("update", lsmbDirective);
    app.use(i18n);
    app.mount(appName);
}
