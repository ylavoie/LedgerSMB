/** @format */

/**
 * OpenAPI tests
 *
 * @group openapi
 */

// Import test packages
import jestOpenAPI from "jest-openapi";
import { StatusCodes } from "http-status-codes";
import { create_database, drop_database } from "./database";
import { fetch } from 'undici';

// Load an OpenAPI file (YAML or JSON) into this plugin
jestOpenAPI(process.env.PWD + "/openapi/API.yaml");

// Set API version to use
const api = "erp/api/v0";

// Access to the database test user
const id = [...Array(6)].map(() => Math.random().toString(12)[2]).join("");
const username = `Jest${id}`;
const password = "Tester";
const company = `lsmb_test_api_${id}`;

const serverUrl = process.env.LSMB_BASE_URL;

let headers = {};

// For all tests
beforeAll(() => {
    create_database(username, password, company);
});

afterAll(() => {
    drop_database(company);
});

const emulateAxiosResponse = async(res) => {
    return {
        data: await res.json(),
        status: res.status,
        statusText: res.statusText,
        headers: res.headers,
        request: {
            path: res.url,
            method: 'GET'
        }
    };
};

// Log in before each test
beforeEach(async () => {
    let r = await fetch(
        serverUrl + "/login.pl?action=authenticate&company=" + encodeURI(company),
        {
            method: "POST",
            body: JSON.stringify({
                company: company,
                password: password,
                login: username
            }),
            headers: {
                "X-Requested-With": "XMLHttpRequest",
                "Content-Type": "application/json"
            }
        }
    );
    if (r.status === StatusCodes.OK) {
        const data = await r.json();
        headers = {
            cookie: r.headers.get("set-cookie"),
            referer: serverUrl + "/" + data.target,
            authorization: "Basic " + btoa(username + ":" + password)
        };
    }
});

// Log out after each test
afterEach(async () => {
    let r = await fetch(serverUrl + "/login.pl?action=logout&target=_top");
    if (r.status === StatusCodes.OK) {
        headers = {};
    }
});

// Business Types tests
describe("Retrieving all Business Types", () => {
    it("GET /contacts/business-types should satisfy OpenAPI spec", async () => {
        // Get an HTTP response from your serverUrl
        let res = await fetch(serverUrl + "/" + api + "/languages", {
            headers: headers
        });
        expect(res.status).toEqual(StatusCodes.OK);

        // Assert that the HTTP response satisfies the OpenAPI spec
        res = await emulateAxiosResponse(res);
        expect(res).toSatisfyApiSpec();
    });
});

describe("Retrieving all Business Types with old syntax should fail", () => {
    it("GET /contacts/business-types/ should fail", async () => {
        const res = await fetch(serverUrl + "/" + api + "/contacts/business-types/", {
            headers: headers
        });
        expect(res.status).toEqual(StatusCodes.BAD_REQUEST);
    });
});

describe("Retrieve non-existant Business Type", () => {
    it("GET /contacts/business-types/1 should not retrieve our Business Types", async () => {
        const res = await fetch(serverUrl + "/" + api + "/contacts/business-types/1", {
            headers: headers
        });
        expect(res.status).toEqual(StatusCodes.NOT_FOUND);
    });
});

describe("Adding the IT Business Types", () => {
    it("POST /contacts/business-types/1 should allow adding Business Type", async () => {
        let res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types",
            {
                method: "POST",
                body: JSON.stringify({
                    description: "Big customer",
                    discount: "0.05"
                }),
                headers: { ...headers, "Content-Type": "application/json" }
            }
        );
        expect(res.status).toEqual(StatusCodes.CREATED);

        // Assert that the HTTP response satisfies the OpenAPI spec
        res = await emulateAxiosResponse(res);
        expect(res.data).toSatisfySchemaInApiSpec("NewBusinessType");
    });
});

describe("Modifying the new Business Type", () => {
    it("PUT /contacts/business-types/1 should allow updating Business Type", async () => {
        let res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types/1",
            {
                headers: headers
            }
        );
        expect(res.status).toEqual(StatusCodes.OK);
        const etag = res.headers.get("etag");
        expect(etag).toBeDefined();
        res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types/1",
            {
                method: "PUT",
                body: JSON.stringify({
                    id: 1,
                    description: "Bigger customer",
                    discount: "0.1"
                }),
                headers: {
                    ...headers,
                    "Content-Type": "application/json",
                    "If-Match": etag
                }
            }
        );
        expect(res.status).toEqual(StatusCodes.OK);

        // Assert that the HTTP response satisfies the OpenAPI spec
        res = await emulateAxiosResponse(res);
        expect(res).toSatisfyApiSpec();

        // Assert that the HTTP response satisfies the OpenAPI spec
        expect(res.data).toSatisfySchemaInApiSpec("BusinessType");
    });
});

/*
 * Not implemented yet
describe("Updating the new Business Type", () => {
    it("PATCH /contacts/business-types/1 should allow updating IT Business Types", async () => {
        let res = await fetch(serverUrl + "/" + api + "/contacts/business-types/1", {
            headers: headers
        });
        expect(res.status).toEqual(StatusCodes.OK);
        const etag = res.headers.get("etag");
        expect(etag).toBeDefined();
        res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types/1",
            {
                method: "PATCH",
                body: JSON.stringify({
                    id: 1,
                    description: "Bigger customer",
                    discount: "0.1"
                }),
                headers: {
                    ...headers,
                    "Content-Type": "application/json",
                    "If-Match": etag
                },
            }
        );
        expect(res.status).toEqual(StatusCodes.OK);

        // Assert that the HTTP response satisfies the OpenAPI spec
        res = await emulateAxiosResponse(res);
        expect(res).toSatisfyApiSpec();

        // Assert that the HTTP response satisfies the OpenAPI spec
        expect(res.data).toSatisfySchemaInApiSpec("Business Types");
    });
});
*/

describe("Not removing the new IT Business Types", () => {
    it("DELETE /contacts/business-types/1 should not allow deleting Business Type", async () => {
        let res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types/1",
            {
                headers: headers
            }
        );
        expect(res.status).toEqual(StatusCodes.OK);
        const etag = res.headers.get("etag");
        expect(etag).toBeDefined();
        res = await fetch(
            serverUrl + "/" + api + "/contacts/business-types/1", {
                method: "DELETE",
                headers: { ...headers, "If-Match": etag }
            }
        );
        expect(res.status).toEqual(StatusCodes.FORBIDDEN);
    });
});
