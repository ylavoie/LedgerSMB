<!-- @format -->
<!-- prettier-ignore -->

<template>
    <div class="login">
        <div id="logindiv">
            <div class="login" align="center">
                <h1 class="login">Database Management Console</h1>
                <a href="http://www.ledgersmb.org/" target="_top">
                    <img src="images/ledgersmb.png" class="logo" alt="LedgerSMB Logo"/>
                </a>
                <h2 align="center" style="margin-top: 0">
                    LedgerSMB {{ version }}
                </h2>
                <div class="listtop">Database administrator credentials</div>
            </div>
            <form id="loginform" name="credentials">
                <div class="login_form">
                    <div class="tabular col-1">
                        <div id="userpass">
                            <div id="company_div">
                                <!--
                                <lsmb-select id = "s-user" name = "s_user"
                                    size="15" tabindex=1
                                    autocomplete="off" class="username"
                                    label = {{ $t("DB admin login") }}
                                    select_hint= {{ $t("Select or Enter User") }}

                                    options =  [ { value = 'lsmb_dbadmin', text = 'lsmb_dbadmin'},
                                                { value = 'postgres',     text = 'postgres'} ]
                                        "data-dojo-type" = "dijit/form/ComboBox"
                                        "data-dojo-props" = "value:'$s_user', placeHolder:'$select_hint'"
                                />
                                -->
                                <lsmb-text id="s-user" v-update:s_user="" type="text"
                                            name="s_user" size="15"
                                            title="DB admin login" tabindex="1"
                                            :value="s_user"
                                            autocomplete="off" />
                                <lsmb-password id="password" v-update:password=""
                                                type="password" name="password"
                                                size="20" title="Password" :value="password"
                                                tabindex="2" autocomplete="off" />
                                <lsmb-text v-update:database="" type="text" name="database"
                                            size="15" title="Database" tabindex="3"
                                            :value="database" />
                            </div>
                        </div>
                    </div>
                    <div class="inputrow buttons">
                        <lsmb-button id="login" tabindex="4" @click="login">Login</lsmb-button>
                        <lsmb-button id="create" tabindex="5" @click="create">Create</lsmb-button>
                    </div>
                </div>
            </form>
        </div>
        <div v-show="inProgress" id="loading">
            {{ $t('Loading...') }}
        </div>
    </div>
</template>

<script>
/* eslint-disable no-console, no-alert, no-unused-vars */

export default {
    data() {
        return {
            version: window.lsmbConfig.version,
            password: "",
            s_user: "",
            database: "",
            inProgress: false
        };
    },
    mounted() {
        console.log("SetupPage mounted");
        document.body.setAttribute("data-lsmb-done", "true");
    },
    methods: {
        async login() {
            this.inProgress = true;
            let r = await fetch("setup.pl?action=authenticate&company=postgres",
            {
                method: "POST",
                body: JSON.stringify({
                    password: this.password,
                    user: this.s_user
                }),
                headers: new Headers({
                    "X-Requested-With": "XMLHttpRequest",
                    "Content-Type": "application/json"
                })
            });
            console.log(r);
            if (r.ok) {
                let data = await r.json();
                window.location.href =
                    "setup.pl?action=" + this.action +
                    "&database=" + encodeURI(this.database);
                return;
            }
            if (r.status === 454) {
                alert(this.$t("Company does not exist"));
            } else if (r.status === 401) {
                alert(this.$t("Access denied: Bad username or password"));
            } else {
                alert(this.$t("Unknown error preventing login"));
            }
            this.inProgress = false;
        }
    }
};
</script>

<style scoped>
#loading {
    display: block;
    margin: auto auto;
}
@import '../../css/setup.css';
@import '../../css/system/global.css';
</style>
