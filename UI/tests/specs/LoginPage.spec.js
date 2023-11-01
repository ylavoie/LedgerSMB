/** @format */
/* global retry */

import { describe, expect, it } from '@jest/globals';
import { installQuasarPlugin } from '@quasar/quasar-app-extension-testing-unit-jest';

import { mount } from "@vue/test-utils";

import LoginPage from "@/views/LoginPage.vue";

installQuasarPlugin();

let wrapper;

describe("LoginPage", () => {
    it("should show dialog", () => {
        wrapper = mount(LoginPage);
        expect(wrapper.find("h1.login").text()).toMatch(/[\d.](-dev)?/);

        console.log(wrapper.html());
        expect(wrapper.get('[name="username"]').element.value).toBe("");
        expect(wrapper.get('[name="password"]').element.value).toBe("");
        expect(wrapper.get('[name="company"]').element.value).toBe("");

        const loginButton = wrapper.get('[name="login"]');

        expect(loginButton.text()).toBe("Login");
        expect(loginButton.isDisabled()).toBe(true);
    });

    it("should enable login button when filled", async () => {
        wrapper = mount(LoginPage);

        const loginButton = wrapper.get("#login");
        expect(await loginButton.isDisabled()).toBe(true);

        wrapper.find('[name="username"]').setValue("MyUser");
        expect(await loginButton.isDisabled()).toBe(true);

        wrapper.find('[name="password"]').setValue("MyPassword");
        expect(await loginButton.isDisabled()).toBe(false);

        wrapper.find('[name="company"]').setValue("MyCompany");
        expect(await loginButton.isDisabled()).toBe(false);
    });

    it("should fail on bad user", async () => {
        const jsdomAlert = window.alert; // remember the jsdom alert
        window.alert = jest.fn(); // provide an empty implementation for window.alert

        wrapper = mount(LoginPage);

        wrapper.find('[name="username"]').setValue("BadUser");
        expect(await wrapper.get("#login").isDisabled()).toBe(true);

        wrapper.find('[name="password"]').setValue("MyPassword");
        expect(await wrapper.get("#login").isDisabled()).toBe(false);

        wrapper.find('[name="company"]').setValue("MyCompany");
        expect(await wrapper.get("#login").isDisabled()).toBe(false);

        await wrapper.get("#login").trigger("click");

        await retry(() => expect(wrapper.get("#errorText").text()).toBe(
            "Access denied: Bad username or password"
        ));
        window.alert = jsdomAlert; // restore the jsdom alert
    });

    it("should fail on bad version", async () => {
        const jsdomAlert = window.alert; // remember the jsdom alert
        window.alert = jest.fn(); // provide an empty implementation for window.alert

        wrapper = mount(LoginPage);

        await wrapper.find('[name="username"]').setValue("MyUser");
        await wrapper.find('[name="password"]').setValue("MyPassword");
        await wrapper.find('[name="company"]').setValue("MyOldCompany");

        await wrapper.get("#login").trigger("click");

        await retry (() => expect(wrapper.get("#errorText").text()).toBe(
            "Database version mismatch"
        ));
        window.alert = jsdomAlert; // restore the jsdom alert
    });

    it("should fail unknown error", async () => {
        const jsdomAlert = window.alert; // remember the jsdom alert
        window.alert = jest.fn(); // provide an empty implementation for window.alert

        wrapper = mount(LoginPage);

        await wrapper.find('[name="username"]').setValue("My");
        await wrapper.find('[name="password"]').setValue("My");
        await wrapper.find('[name="company"]').setValue("My");

        await wrapper.get("#login").trigger("click");

        await retry(() => expect(window.alert).toHaveBeenCalledTimes(1));
        expect(window.alert).toHaveBeenCalledWith(
          "Unknown error preventing login",
        );
        window.alert = jsdomAlert; // restore the jsdom alert
    });

    it("should login when filled", async () => {
        wrapper = mount(LoginPage);

        await wrapper.find('[name="username"]').setValue("MyUser");
        await wrapper.find('[name="password"]').setValue("MyPassword");
        await wrapper.find('[name="company"]').setValue("MyCompany");

        await wrapper.get("#login").trigger("click");

        expect(wrapper.get(".v-enter-active").text())
            .toBe("Logging in... Please wait.");

        await retry(() => expect(window.location.assign).toHaveBeenCalledTimes(1));
        expect(window.location.assign).toHaveBeenCalledWith(
          'http://lsmb/erp.pl?action=root',
        );
    });
});
