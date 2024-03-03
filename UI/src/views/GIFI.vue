<script setup>

import { useGIFIsStore } from "@/store/gifis";
import { useI18n } from "vue-i18n";
import ConfigTable from "@/components/ConfigTable.vue";

import ImportCsvGifi from "@/views/ImportCSV-GIFI";

const { t } = useI18n();
const COLUMNS = [
    { key: "accno", type: "text",            head: t("Code") },
    { key: "description", type: "text",      head: t("Description") },
];

const store = useGIFIsStore();

</script>

<template>
    <!-- eslint-disable vue/attribute-hyphenation -->
    <h5 class="listtop">{{ $t("Configure GIFI codes") }}</h5>
    <ConfigTable
        :columns="COLUMNS"
        :store="store"
        storeId="accno"
        editRole="gifi_edit"
        createRole="gifi_create" />
    <div class="import-section">
        <h6 class="listheading">{{ $t("Import") }}</h6>
        <ImportCsvGifi @upload-success="store.initialize()" />
    </div>
</template>

<style scoped>

.import-section {
    margin-top: 3em;
}

.import-section h6 {
    text-align: left;
}

</style>
