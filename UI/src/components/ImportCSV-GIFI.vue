<template>
   <div id="import-gifi">
      <import-csv :type="type">
        <template v-slot:title>Import <abbr
           :title="this.$t('General Index of Financial Information')">GIFI</abbr> codes
        </template>
        <template v-slot:info>
           {{ $t('The uploaded file contains one GIFI code per line.') }}
        </template>
        <template v-slot:default>
           {{ $t('The following fields are expected (in this order):') }}

           <dl>
             <dt>code</dt>
             <dd></dd>
             <dt>sictype</dt>
             <dd></dd>
             <dt>description</dt>
             <dd></dd>
           </dl>
        </template>
      </import-csv>
   </div>
</template>

<style scoped>
dl > dt {
  font-weight: bold;
  margin-left: 2em;
}

dl > dd {
  margin-left: 4em;
}
</style>

<script>

import ImportCSVBase from "./ImportCSV-Base";


export default {
    components: {
       "import-csv": ImportCSVBase
    },
    data() {
       return {
          type: "gifi"
       };
    }
};
</script>
