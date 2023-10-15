<script setup>
  import { ref, computed, onMounted } from 'vue';
  import { useI18n } from 'vue-i18n';
  import { setI18nLanguage } from '@/i18n';

  const { t, locale } = useI18n({ useScope: 'global' });
  setI18nLanguage(locale);

  let searchParams = new URL(document.location).searchParams;
  const version = ref(window.lsmbConfig.version);
  const username = ref(searchParams.get('login') || '');
  const password = ref('');
  const company = ref(searchParams.get('company') || '');
  const errorText = ref('');
  const isInProgress = ref(false);

  const isLoginDisabled = computed(() => !username.value || !password.value);

  const login = async () => {

    // Check if login is disabled
    if (isLoginDisabled.value) {
      return;
    }

    // Set login progress to true
    isInProgress.value = true;

    try {
      const response = await fetch(`login.pl?action=authenticate&company=${encodeURI(company.value)}`, {
        method: 'POST',
        body: JSON.stringify({
          company: company.value,
          password: password.value,
          login: username.value,
        }),
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/json',
        },
      });

      if (response.ok) {
        const data = await response.json();
        window.location.assign(data.target);
        return;
      }

      // Handle different response statuses
      if (response.status === 401) {
        errorText.value = t('Access denied: Bad username or password');
      } else if (response.status === 521) {
        errorText.value = t('Database version mismatch');
      } else {
        errorText.value = t('Unknown error preventing login');
      }
    } catch (error) {
      errorText.value = t('An error occurred during login:', error);
    } finally {
      // Set login progress to false
      isInProgress.value = false;
    }
  };

  onMounted(() => {
    document.body.setAttribute('data-lsmb-done', 'true');
  });
</script>

<template>
  <q-form class="column q-pa-xs shadow=2" name="login" style="max-width: fit-content">
    <div id="logindiv">
      <div class="login" align="center">
        <a href="http://www.ledgersmb.org/" target="_top">
          <img src="images/ledgersmb.png" class="logo" alt="LedgerSMB Logo" />
        </a>
        <div id="maindiv">
          <div class="maindivContent">
            <div>
              <q-input
                v-model="username"
                name="username"
                size="20"
                autocomplete="off"
                required
                type="text"
                dense
                :rules="[val => !!val || $t('Username is required')]"
              >
                <template #before>
                  <q-item-label>{{$t('User Name')}}</q-item-label>
                </template>
              </q-input>
              <q-input
                v-model="password"
                name="password"
                size="20"
                autocomplete="off"
                required
                type="password"
                dense
                :rules="[val => !!val || $t('Password is required')]"
              >
                <template #before>
                  <q-item-label>{{$t('Password')}}</q-item-label>
                </template>
              </q-input>
              <q-input v-model="company" name="company" size="20" autocomplete="off" type="text" dense>
                <template #before>
                  <q-item-label>{{$t('Company')}}</q-item-label>
                </template>
              </q-input>
            </div>
            <q-btn
              name="loginButton"
              color="primary"
              type="submit"
              :loading="isInProgress"
              dense
              :disable="isLoginDisabled"
              :label="$t('Login')"
              @click="login"
            >
              <template #loading>
                <q-spinner-facebook />
              </template>
            </q-btn>
            <div v-if="errorText" id="errorText">{{ errorText }}</div>
          </div>
        </div>
        <transition>
          <div v-if="isInProgress">{{ $t("Logging in... Please wait.") }}</div>
        </transition>
      </div>
    </div>
  </q-form>
  <p class="login" align="center">{{ version }}</p>
</template>

<style scoped>
#maindiv {
  position: relative;
  min-width: max-content;
  height: 15em;
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
