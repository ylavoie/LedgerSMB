<script>
import { defineComponent, ref } from "vue";
import { useI18n } from "vue-i18n";
import { setI18nLanguage } from "@/i18n";

export default defineComponent({
    name: "LoginPage",
    setup() {
        const { t, locale } = useI18n({ useScope: "global" });

        setI18nLanguage(locale);
        let searchParams = new URL(document.location).searchParams;
        let username = searchParams.get("login") || "";
        let company = searchParams.get("company") || "";
        let data = {
            t: t,
            form: ref(null),
            password: ref(""),
            username: ref(""),
            company: ref(""),
            form: ref(null),
            errorText: ref(""),
            inProgress: ref(false)
        };

        return {
            version: window.lsmbConfig.version,
            ...data
        };
    },
    computed: {
        loginDisabled() {
            return !this.username || !this.password
        }
    },
    mounted() {
        document.body.setAttribute("data-lsmb-done", "true");
    },
    methods: {
        async login() {
            if (this.loginDisabled) {
                return;
            }

            this.inProgress = true;
            let r = await fetch("login.pl?action=authenticate&company=" + encodeURI(this.company), {
                method: "POST",
                body: JSON.stringify({
                    company: this.company,
                    password: this.password,
                    login: this.username
                }),
                headers: new Headers({
                    "X-Requested-With": "XMLHttpRequest",
                    "Content-Type": "application/json"
                })
            });
            if (r.ok) {
                let data = await r.json();
                window.location.href = data.target;
                return;
            }
            if ( r.status === 401 ) {
                this.errorText = this.$t("Access denied: Bad username or password")
            } else if ( r.status === 521 ) {
                this.errorText = this.$t("Database version mismatch")
            } else {
                this.errorText = this.$t("Unknown error preventing login");
            }
            this.inProgress = false;
        }
    }
});
</script>

<template>
    <q-form ref="form" class="column q-pa-xs shadow=2"
            name="login" style="max-width:fit-content"
            @submit="login">
      <div id="logindiv">
        <div class="login" align="center">
          <a href="http://www.ledgersmb.org/"
             target="_top">
            <img src="images/ledgersmb.png"
                 class="logo"
                 alt="LedgerSMB Logo" /></a>
          <div id="maindiv">
            <div class="maindivContent">
              <div>
                <q-input v-model="username"
                         name="username"
                         size="20"
                         :model-value="username"
                         tabindex="1"
                         autocomplete="off"
                         required
                         type="text"
                         dense
                         :rules="[val => !!val || $t('Username is required')]">
                    <template #before>
                        <q-item-label>{{$t('User Name')}}</q-item-label>
                    </template>
                </q-input>
                <q-input v-model="password"
                         name="password"
                         size="20"
                         :model-value="password"
                         tabindex="2"
                         autocomplete="off"
                         required
                         type="password"
                         dense
                         :rules="[val => !!val || $t('Password is required')]">
                    <template #before>
                        <q-item-label>{{$t('Password')}}</q-item-label>
                    </template>
                </q-input>
                <q-input v-model="company"
                         name="company"
                         size="20"
                         tabindex="3"
                         :model-value="company"
                         autocomplete="off"
                         type="text"
                         dense>
                    <template #before>
                        <q-item-label>{{$t('Company')}}</q-item-label>
                    </template>
                </q-input>
              </div>
              <q-btn id="login"
                     name="login"
                     tabindex="4"
                     color="primary"
                     type="submit"
                     :loading="inProgress"
                     :dense="true"
                     :disable="loginDisabled"
                     :label="$t('Login')">
                  <template #loading>
                    <q-spinner-facebook />
                  </template>
                </q-btn>

              <div v-if="errorText" id="errorText" >{{ errorText }}</div>
            </div>
          </div>
          <transition>
             <div v-if="inProgress">{{ $t("Logging in... Please wait.") }}</div>
          </transition>
        </div>
      </div>
    </form>
    <h1 class="login" align="center">
        {{ version }}
    </h1>
</template>

<style scoped>
#maindiv {
  position:relative;
  min-width:max-content;
  height:15em;
}
#logindiv #company_div {
    margin-bottom: 1em;
    margin-top: 2em;
}
.custom-label {
  width: auto;
}
#logindiv #company_div {
    display: block;
    margin-bottom: 1em;
    margin-top: 2em;
}
#logindiv {
    display: contents;
}
.q-item__label {
    font-size: 14px;
}
</style>
