<!-- eslint-disable no-console -->
<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { setI18nLanguage } from '@/i18n';

const { t, locale } = useI18n({ useScope: 'global' });
setI18nLanguage(locale);

const version = ref(window.lsmbConfig.version);
const username = ref('');
const password = ref('');
const database = ref('');
const errorText = ref('');
const isLoginInProgress = ref(false);
const isCreateInProgress = ref(false);

const stringOptions = ['lsmb_dbadmin', 'postgres'];

const options = ref(stringOptions);

const isLoginDisabled = computed(() => !username.value || !password.value);
const isCreateDisabled = computed(() => !username.value || !password.value || !database.value);

const action = ref('');

const filterFn  = (val, update) =>{
  update(() => {
    const needle = val.toLocaleLowerCase()
    options.value = stringOptions.filter(v => v.toLocaleLowerCase().indexOf(needle) > -1)
  })
};

const setUsername = (val) =>{
  username.value = val
};

const login = async () => {

  // Check if login is disabled
  if (isLoginDisabled.value || isCreateDisabled.value) {
    return;
  }

  // Set login progress to true
  // isInProgress.value = true;
  // isInProgress.value = true;
  let xhr = new XMLHttpRequest();

  try {
    xhr.open('GET', 'setup.pl?action=authenticate&company=postgres', true, username.value, password.value);
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhr.onload = function () {
      if (xhr.status === 200) {
        const encodedDatabase = encodeURI(database.value);
        const actionValue = action.value;
        const csrfElement = document.getElementById("csrf-token");
        const token = encodeURI(csrfElement ? csrfElement.value : '');
        window.location.assign(`setup.pl?action=${actionValue}&database=${encodedDatabase}&csrf_token=${token}`);
      }
      // Handle different response statuses
      else if (xhr.status === 454) {
        errorText.value = t('Company does not exist');
      } else if (xhr.status === 401) {
        errorText.value = t('Access denied: Bad username/password');
      } else {
        errorText.value = t('Unknown error: ' + xhr.status);
      }
    }
    xhr.send(null);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.log(t('An error occurred during login:', error));
    errorText.value = t('An error occurred during login:', error);
  } finally {
    // Set login progress to false
    isLoginInProgress.value = false;
    isCreateInProgress.value = false;
  }
};

const setAction = (value) => {
  action.value = value;
  login()
};

onMounted(() => {
  document.body.setAttribute('data-lsmb-done', 'true');
});
</script>

<template>
  <div style="width:100%;height:100%">
    <div class="setupconsole">
      <div id="logindiv">
        <div class="login" align="center">
          <a href="http://www.ledgersmb.org/" target="_top">
            <img src="images/ledgersmb.png" class="logo" alt="LedgerSMB Logo" />
          </a>
          <h6 align="center" style="margin-top: 0">{{ version }}</h6>
          <div class="listtop">{{ $t('Database administrator credentials') }}</div>
        </div>
        <q-form align="center">
          <q-card id="loginform" name="credentials"
          class="login-card">
            <q-card-section id="logindiv">
              <div class="login_form">
                  <q-select
                    name="s_user"
                    :model-value="username"
                    use-input
                    hide-selected
                    fill-input
                    input-debounce="0" required
                    options-dense :options="options" dense
                    :hint="$t('Select or Enter User')"
                    style="width: auto;"
                    :rules="[val => !!val || $t('DB admin login is required')]"
                    @filter="filterFn"
                    @input-value="setUsername"
                  >
                    <template #no-option>
                      <q-item>
                        <q-item-section class="text-grey">
                          No results
                        </q-item-section>
                      </q-item>
                    </template>
                    <template #before>
                      <q-item-label>{{$t('DB admin login')}}</q-item-label>
                    </template>
                  </q-select>
                <q-input
                  v-model="password"
                  name="s_password"
                  size="15"
                  autocomplete="off"
                  required
                  type="password"
                  dense
                  style="width: auto"
                  :rules="[val => !!val || $t('Password is required')]"
                >
                  <template #before>
                    <q-item-label>{{$t('Password')}}</q-item-label>
                  </template>
                </q-input>
                <q-input v-model="database" name="database" size="15"
                  style="width: auto"
                  autocomplete="off" dense>
                  <template #before>
                    <q-item-label>{{$t('Database')}}</q-item-label>
                  </template>
                </q-input>
              </div>
            </q-card-section>
            <q-card-actions align="center">
              <q-btn
                name="setupLoginButton"
                color="primary"
                type="submit"
                :loading="isLoginInProgress"
                dense
                :disable="isLoginDisabled"
                :label="$t('Login')"
                @click="setAction('login')"
              />
              <q-btn
                name="setupCreateButton"
                color="primary"
                type="submit"
                :loading="isCreateInProgress"
                dense
                :disable="isCreateDisabled"
                :label="$t('Create')"
                @click="setAction('create_db')"
              />
            </q-card-actions>
            <transition>
              <div v-if="isLoginInProgress">{{ $t("Logging in... Please wait.") }}</div>
            </transition>
            <transition>
              <div v-if="isCreateInProgress">{{ $t("Creating... Please wait.") }}</div>
            </transition>
            <div v-if="errorText" id="errorText">{{ errorText }}</div>
          </q-card>
        </q-form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-card {
  margin-top: 1em;
  max-width: fit-content;
}

#loginform {
  display: inline-block;
  min-width: max-content;
}

.login_form {
  display: block;
  text-align: left;
}

label {
  margin: 0;
}

.q-item__label {
  font-size: 14px;
}
</style>
