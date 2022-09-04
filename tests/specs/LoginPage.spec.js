/** @format */
/* eslint-disable max-classes-per-file, no-console, vue/component-definition-name-casing */

import { mount } from "@vue/test-utils";
import { enableFetchMocks } from "jest-fetch-mock";

import { i18n } from "../common/i18n";
import LoginPage from "@/views/LoginPage.vue";

enableFetchMocks();

let wrapper;

describe("LoginPage.vue", () => {
    beforeEach(() => {
        fetch.resetMocks();
        Object.assign(window, {
            // window object does not exist in JSDom
            alert: jest.fn()
        });
    });

    it("should show dialog", async () => {
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    version: "LedgerSMB 1.10.0-dev"
                };
            }
        });
        expect(wrapper.find(".login").text()).toMatch(/LedgerSMB [\d.](-dev)?/);

        expect(wrapper.get("#username").element.value).toBe("");
        expect(wrapper.get("#password").element.value).toBe("");
        expect(wrapper.get("#company").element.value).toBe("");

        const loginButton = wrapper.get("#login");

        expect(loginButton.text()).toBe("Login");
        expect(loginButton.element.disabled).toBe(true);
    });

    it("should enable login button when filled", async () => {
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    version: "LedgerSMB 1.10.0-dev",
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyCompany"
                };
            }
        });
        expect(wrapper.get("#username").element.value).toBe("MyUser");
        expect(wrapper.get("#password").element.value).toBe("MyPassword");
        expect(wrapper.get("#company").element.value).toBe("MyCompany");

        const loginButton = wrapper.get("#login");

        expect(loginButton.text()).toBe("Login");
        expect(loginButton.element.disabled).toBe(false);
    });

    it("should login when filled", async () => {
        fetch.mockResponseOnce(
            JSON.stringify({
                target: "login.pl?action=authenticate&company=MyCompany",
                status: 200
            })
        );
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyCompany"
                };
            }
        });
        const loginButton = wrapper.get("#login");
        await loginButton.trigger("click");

        // assert on the times called and arguments given to fetch
        expect(fetch.mock.calls).toHaveLength(1);
        expect(window.location.href).toEqual(
            "login.pl?action=authenticate&company=MyCompany"
        );
    });

    it("should fail on non-existent company", async () => {
        fetch.mockResponse(
            {},
            {
                status: 454
            }
        );
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyComp4ny"
                };
            }
        });
        const loginButton = wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith("Company does not exist");
    });

    it("should fail on bad user", async () => {
        fetch.mockResponse(
            {},
            {
                status: 401
            }
        );
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    username: "BadUser",
                    password: "MyPassword",
                    company: "MyComp4ny"
                };
            }
        });
        const loginButton = wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith(
            "Access denied: Bad username or password"
        );
    });

    it("should fail on bad version", async () => {
        fetch.mockResponse(
            {},
            {
                status: 521
            }
        );
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyComp4ny"
                };
            }
        });
        const loginButton = wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith("Database version mismatch");
    });

    it("should fail unknown error", async () => {
        fetch.mockResponse(
            {},
            {
                status: 999
            }
        );
        wrapper = mount(LoginPage, {
            global: {
                plugins: [i18n]
            },
            directives: {
                update: () => jest.fn()
            },
            data() {
                return {
                    username: "My",
                    password: "My",
                    company: "My"
                };
            }
        });
        const loginButton = wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith(
            "Unknown error preventing login"
        );
    });
});
