/** @format */

export const SUPPORT_LOCALES = ["en", "fr_CA"];
import { createI18n } from "vue-i18n";

// we build a main file with the default locale, the other languages are loaded later
const defaultLocale = process.env.VUE_APP_I18N_LOCALE || "en";

var _messages = {};
SUPPORT_LOCALES.forEach(function (it) {
    // eslint-disable-next-line global-require
    _messages[it] = require("@/locales/" + it + ".json");
});

// set <html lang="en" />
// document.documentElement.setAttribute("lang", defaultLocale);

export const i18n = createI18n({
    useScope: "global",
    legacy: false,
    fallbackWarn: false,
    missingWarn: false, // warning off
    locale: defaultLocale,
    fallbackLocale: defaultLocale,
    messages: _messages
});
