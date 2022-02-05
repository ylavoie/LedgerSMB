<!-- @format -->
<!-- prettier-ignore -->

<template>
    <div style="width:100%;height:100%">
        <form id="setupconsole">
            <div id="logindiv">
                <div class="login" align="center">
                    <h1 class="login">{{ $t('Database Management Console') }}</h1>
                    <a href="http://www.ledgersmb.org/" target="_top">
                        <img src="images/ledgersmb.png" class="logo" alt="LedgerSMB Logo"/>
                    </a>
                    <h2 align="center" style="margin-top: 0">
                        LedgerSMB {{ version }}
                    </h2>
                    <div class="listtop">{{ $t('Database administrator credentials') }}</div>
                </div>
                <div id="loginform" name="credentials">
                    <div class="login_form">
                        <div class="tabular col-1">
                            <div id="userpass">
                                <div id="company_div">
                                    <lsmb-combobox v-update:value="username"
                                        id = "s-user" name = "s_user"
                                        size="15" tabindex=1
                                        autocomplete="off" class="username"
                                        :label = "$t('DB admin login')"
                                        :options = "s_user_options"
                                        :placeHolder = "$t('Select or Enter User')" />
                                    <lsmb-password id="s-password" v-update:password=""
                                                    type="password" name="s_password"
                                                    size="20" :title="$t('Password')" :value="password"
                                                    tabindex="2" autocomplete="off" />
                                    <lsmb-text v-update:database="" type="text" name="database"
                                                size="15" :title="$t('Database')" tabindex="3"
                                                :value="database" />
                                </div>
                            </div>
                        </div>
                        <div class="inputrow buttons">
                            <lsmb-button id="login" tabindex="4" @click="login">{{ $t('Login') }}</lsmb-button>
                            <lsmb-button id="create" tabindex="5" @click="login">{{ $t('Create') }}</lsmb-button>
                        </div>
                    </div>
                </div>
            </div>
            <div v-show="inProgress" id="loading">
                {{ $t('Loading...') }}
            </div>
        </form>
    </div>
</template>

<script>
/* eslint-disable no-console, no-alert, no-unused-vars */
import { defineComponent } from 'vue';
import { detectLanguage, loadLocaleMessages } from '../i18n.js';

export default defineComponent({
    name: 'SetupPage',
    setup() {
        loadLocaleMessages(detectLanguage());
    },
    data() {
        return {
            version: window.lsmbConfig.version,
            username: "",
            password: "",
            database: "",
            inProgress: false,
            s_user_options: [
                { text: "lsmb_dbadmin", id: "lsmb_dbadmin" },
                { text: "postgres", id: "postgres" }
            ]
        };
    },
    mounted() {
        document.body.setAttribute("data-lsmb-done", "true");
    },
    methods: {
        async _fetch(action) {
            this.inProgress = true;
            console.log(this);
            let r = await fetch("setup.pl?action=authenticate&company=postgres",
            {
                method: "POST",
                body: JSON.stringify({
                    password: this.password,
                    user: this.username
                })
            });
            if (r.ok) {
                window.location.href = "setup.pl?action=" + action +
                            "&database=" + encodeURI(this.database);
            }
            else if (r.status === 454) {
                alert(this.$t("Company does not exist"));
            } else {
                alert(this.$t("Access denied ({ status }): Bad username/password", { status: r.status } ));
            }
            this.inProgress = false;
        },
        login() {
            this._fetch('login');
        },
        create() {
            this._fetch('create_db');
        }
    }
})
</script>

<style scoped>
#setupconsole {
    position: relative;
    height: 100%;
}
.login {
    font-weight: bold;
    margin-top:0;
    margin-bottom: 1em;
}
h2 {
    margin-top: 0
}
#loginform {
    margin-top: 1em;
}
#s-user {
    display: contents;
}
#logindiv {
    width: 350px;
}
.buttons {
    text-align: center;
    padding-right: 4ex;
    margin-top: 1ex
}
</style>
