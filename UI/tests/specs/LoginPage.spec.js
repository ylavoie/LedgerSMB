/* eslint-disable jest/no-hooks */
/* eslint-disable jest/require-hook */
/** @format */
/* global retry */

import { describe, expect, it } from '@jest/globals';
import { installQuasarPlugin } from '@quasar/quasar-app-extension-testing-unit-jest';

import { mount } from "@vue/test-utils";

import LoginPage from "@/views/LoginPage.vue";

installQuasarPlugin();

let wrapper;
let username;
let password;
let company;
let loginButton;

describe("loginPage", () => {
    beforeEach(() => {
        jest.spyOn(window, 'alert').mockImplementation();
        wrapper = mount(LoginPage);
        expect(wrapper.find("p.login").text()).toMatch(/[\d.](-dev)?/);

        username = wrapper.get('[name="username"]');
        password = wrapper.get('[name="password"]');
        company = wrapper.get('[name="company"]');

        loginButton = wrapper.get('[name="loginButton"]');
    });

    const fillAndSubmit = async (user, pass, comp) => {

        await username.setValue(user);
        await password.setValue(pass);
        await company.setValue(comp);

        await loginButton.trigger("click");
    };

    it("should show dialog", () => {
        expect(wrapper.find("p.login").text()).toMatch(/[\d.](-dev)?/);
        expect(username.element.value).toBe("");
        expect(password.element.value).toBe("");
        expect(company.element.value).toBe("");
        expect(loginButton.text()).toBe("Login");
        expect(loginButton.isDisabled()).toBe(true);
    });

    it("should enable login button when filled", async () => {
        await username.setValue("MyUser");
        await password.setValue("MyPassword");
        await company.setValue("MyCompany");
        expect(username.element.value).toBe("MyUser");
        expect(password.element.value).toBe("MyPassword");
        expect(company.element.value).toBe("MyCompany");
        expect(await loginButton.isDisabled()).toBe(false);
    });

    it("should fail on bad user", async () => {
        await fillAndSubmit("BadUser", "MyPassword", "MyCompany");
        await retry(() => expect(wrapper.get("#errorText").text()).toBe("Access denied: Bad username or password"));
    });

    it("should fail on bad version", async () => {
        await fillAndSubmit("MyUser", "MyPassword", "MyOldCompany");
        await retry(() => expect(wrapper.get("#errorText").text()).toBe("Database version mismatch"));
    });

    it("should fail unknown error", async () => {
        await fillAndSubmit("My", "My", "My");
        await retry(() => expect(wrapper.get("#errorText").text()).toBe("Unknown error preventing login"));
    });

    it("should login when filled", async () => {
        await fillAndSubmit("MyUser", "MyPassword", "MyCompany");
        expect(await wrapper.get(".v-enter-active").text()).toBe("Logging in... Please wait.");
        await retry(() => expect(window.location.assign).toHaveBeenCalledTimes(1));
        expect(window.location).toBeAt("/erp.pl?__action=root");
    });
});
