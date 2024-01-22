/* eslint-disable jest/require-hook */
/* eslint-disable jest/max-expects */
/* eslint-disable jest/no-hooks */
/* eslint-disable no-unused-vars */
/** @format */
/* global retry */

import { describe, expect, it } from '@jest/globals';
import { installQuasarPlugin } from '@quasar/quasar-app-extension-testing-unit-jest';

import { mount } from '@vue/test-utils';

import SetupLoginPage from '@/views/SetupLoginPage.vue';

installQuasarPlugin();

let wrapper;
let username;
let password;
let database;
let loginButton;
let createButton;

describe('setupLoginPage', () => {
    beforeEach(() => {
        jest.spyOn(window, 'alert').mockImplementation();
        wrapper = mount(SetupLoginPage);

        username = wrapper.get('[name="s_user"]');
        password = wrapper.get('[name="s_password"]');
        database = wrapper.get('[name="database"]');

        loginButton = wrapper.get('[name="setupLoginButton"]');
        createButton = wrapper.get('[name="setupCreateButton"]');
    });

    const fillAndSubmit = async (user, pass, db, btn) => {

        await username.setValue(user);
        await password.setValue(pass);
        await database.setValue(db);

        if (btn) {
            await btn.trigger('click');
        }
    };

    it('should show dialog', () => {
        expect(wrapper.find('h2').text()).toMatch(/[\d.](-dev)?/);
        expect(username.element.value).toBe('');
        expect(password.element.value).toBe('');
        expect(database.element.value).toBe('');
        expect(loginButton.text()).toBe('Login');
        expect(loginButton.isDisabled()).toBe(true);
        expect(createButton.text()).toBe('Create');
        expect(createButton.isDisabled()).toBe(true);
    });

    it('should enable login button when filled', async () => {
        await fillAndSubmit('postgres', 'MyPassword', 'MyCompany');
        expect(username.element.value).toBe('MyUser');
        expect(password.element.value).toBe('MyPassword');
        expect(database.element.value).toBe('MyCompany');
        expect(loginButton.isDisabled()).toBe(false);
        expect(createButton.isDisabled()).toBe(false);
    });

    it('should fail on bad user', async () => {
        await fillAndSubmit('BadUser', 'MyPassword', 'MyCompany', loginButton);
        await retry(() => expect(wrapper.get('#errorText').text()).toBe('Access denied: Bad username or password'));
    });

    it('should fail on bad version', async () => {
        await fillAndSubmit('MyUser', 'MyPassword', 'MyOldCompany', loginButton);
        await retry(() => expect(wrapper.get('#errorText').text()).toBe('Database version mismatch'));
    });

    it('should fail unknown error', async () => {
        await fillAndSubmit('My', 'My', 'My', loginButton);
        await retry(() =>expect(wrapper.get('#errorText').text()).toBe('Unknown error preventing login'));
    });

    it('should login when filled', async () => {
        await fillAndSubmit('MyUser', 'MyPassword', 'MyCompany', loginButton);
        await expect(wrapper.get('.v-enter-active').text()).resolves.toBe('Logging in... Please wait.');
        await retry(() => expect(window.location.assign).toHaveBeenCalledTimes(1));
        expect(window.location.assign).toHaveBeenCalledWith(window.location+'erp.pl?__action=root');
    });

    it('should create when filled', async () => {
        await fillAndSubmit('MyUser', 'MyPassword', 'MyCompany', createButton);
        await expect(wrapper.get('.v-enter-active').text()).resolves.toBe('Creating... Please wait.');
        await retry(() => expect(window.location.assign).toHaveBeenCalledTimes(1));
        expect(window.location.assign).toHaveBeenCalledWith(window.location+'erp.pl?__action=create');
    });
});
