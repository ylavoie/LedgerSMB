<template>
   <div id="import-sic">
      <import-csv :type="type">
        <template v-slot:title>Import <abbr
            :title="this.$t('Standard Industrial Classification')">SIC</abbr> codes</template>
        <template v-slot:info>
           {{ $t('The uploaded file contains one SIC code per line.') }}
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
          type: "sic"
       };
    }
};
</script>
