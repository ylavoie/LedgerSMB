/** @format */
/* global __SUPPORTED_LOCALES */
/* eslint-disable global-require */
// See https://vue-i18n.intlify.dev/guide/
// And https://vue-i18n.intlify.dev/guide/advanced/wc.html#make-preparetion-for-web-components-to-host-the-i18n-instance

const en = require("./locales/en.json");
export const SUPPORT_LOCALES = __SUPPORTED_LOCALES;

import { createI18n } from "vue-i18n";

export function detectLanguage() {
    let language;
    let languages;
    try {
        language =
            (!!window.lsmbConfig.language && window.lsmbConfig.language) ||
            (window.navigator.languages && window.navigator.languages[0]) ||
            window.navigator.language ||
            window.navigator.userLanguage ||
            "en";
        languages = [
            language,
            language.toLowerCase(),
            language.substr(0, 2)
        ].map((l) => l.replace("-", "_"));
    } catch (e) {
        return "en";
    }
    do {
        language = languages.shift();
    } while (
        languages.length &&
        (!language || !SUPPORT_LOCALES.includes(language))
    );
    return language;
}

const i18n = createI18n({
    globalInjection: true,
    legacy: false,
    fallbackWarn: false,
    missingWarn: false, // warning off
    locale: detectLanguage(),
    fallbackLocale: "en",
    messages: {
        en: en
    }
});

export async function loadLocaleMessages(locale) {
    if (SUPPORT_LOCALES.includes(locale)) {
        // load locale messages
        if (!i18n.global.availableLocales.includes(locale)) {
            // load locale messages with dynamic import
            const messages = await import(
                /* webpackChunkName: "locale-[request]" */ `./locales/${locale}.json`
            );

            // set locale and locale messages
            i18n.global.setLocaleMessage(locale, messages);
        }
        // Update document
        document.querySelector("html").setAttribute("lang", locale);

        // Switch the whole application to this locale
        i18n.global.locale.value = locale;
    }
}

export default i18n;
