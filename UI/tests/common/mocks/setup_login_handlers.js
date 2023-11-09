/* eslint-disable no-console */
import { http, HttpResponse } from 'msw';

// http://fileserver:5000/setup.pl?action=authenticate&company=postgres
// http://fileserver:5000/setup.pl?action=login&database=lsmb_test1&csrf_token=6QWDod-LkuP!0Bty%3C%5Er;yiJ

export const setupLoginHandlers = [

    http.get('setup.pl', async ({ request }) => {

        const url = new URL(request.url);
        const action = url.searchParams.get('action');
        const company = url.searchParams.get('company');
//        const database = url.searchParams.get('database');
//        const csrf = url.searchParams.get('csrf_token');

        if ( action === 'authenticate' ) {
            if ( company === 'postgres' ) {
                return HttpResponse.text(
                    'Success',
                {
                    status: 200
                })
            }
            return new HttpResponse.error('Failed to connect');
        }
        /*
        // How to test login?
        if ( action === 'login') {
            if ( database === 'MyCompany' ) {
                return HttpResponse.text(
                    'Success',
                {
                    status: 200
                })
            }
            if ( database === 'MyOldCompany' ) {
                return new HttpResponse(null, {
                    status: 454
                  })
            }
            if ( database === 'MyBadAuthentification' ) {
                return new HttpResponse(null, {
                    status: 401
                  })
            }
        }
        // How to test create?
        if ( action === 'create') {
            if ( database === 'MyCompany' ) {
                return HttpResponse.text(
                    'Success',
                {
                    status: 200
                })
            }
        }
        if ( database === 'My' ) {
            return new HttpResponse(null, {
                status: 500
              })
        }
        */
        return new HttpResponse.error('Failed to connect');
    })
]

