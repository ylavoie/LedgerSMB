/** @format */
/* eslint-disable max-classes-per-file, no-console, vue/component-definition-name-casing */

import { mount } from "@vue/test-utils";

import { i18n } from "../common/i18n";
import LoginPage from "@/views/LoginPage.vue";

let wrapper;
const testOptions = {
    global: {
        plugins: [i18n]
    },
    directives: {
        update: () => jest.fn()
    }
};

describe("LoginPage.vue", () => {
/*    beforeEach(() => {
        Object.assign(window, {
            // window object does not exist in JSDom
            alert: jest.fn()
        });
    });
*/
    it("register as a component", () => {
        wrapper = mount(LoginPage, testOptions);
        expect(wrapper.exists()).toBeTruthy();
    });

    it("should show dialog", async () => {
        wrapper = mount(LoginPage, {
            ...testOptions,
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
            ...testOptions,
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
        let target = "login.pl?action=authenticate&company=MyCompany";
        wrapper = mount(LoginPage, {
            ...testOptions,
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyCompany"
                };
            }
        });
        const loginButton = await wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.location.href).toEqual(target);
    });

    it("should fail on non-existent company", async () => {
        wrapper = mount(LoginPage, {
            ...testOptions,
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyComp4ny"
                };
            }
        });
        const loginButton = await wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith("Company does not exist");
    });

    it("should fail on bad user", async () => {
        wrapper = mount(LoginPage, {
            ...testOptions,
            data() {
                return {
                    username: "BadUser",
                    password: "MyPassword",
                    company: "MyComp4ny"
                };
            }
        });
        const loginButton = await wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith(
            "Access denied: Bad username or password"
        );
    });

    it("should fail on bad version", async () => {
        wrapper = mount(LoginPage, {
            ...testOptions,
            data() {
                return {
                    username: "MyUser",
                    password: "MyPassword",
                    company: "MyOldComp4ny"
                };
            }
        });
        const loginButton = await wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith("Database version mismatch");
    });

    it("should fail unknown error", async () => {
        wrapper = mount(LoginPage, {
            ...testOptions,
            data() {
                return {
                    username: "My",
                    password: "My",
                    company: "My"
                };
            }
        });
        const loginButton = await wrapper.get("#login");
        await loginButton.trigger("click");

        expect(window.alert).toHaveBeenCalledWith(
            "Unknown error preventing login"
        );
    });
});
