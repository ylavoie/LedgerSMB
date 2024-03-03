<script setup>

import { useWarehousesStore } from "@/store/warehouses";
import { useI18n } from "vue-i18n";
import ConfigTable from "@/components/ConfigTable.vue";

const { t } = useI18n();
const COLUMNS = [
    { key: "description", type: "text",     head: t("Description") },
];

const warehousesStore = useWarehousesStore();

</script>

<template>
    <h5 class="listtop">{{ t("Configure warehouses") }}</h5>
    <ConfigTable
        :columns="COLUMNS"
        :store="warehousesStore"
        storeId="id"
        editRole="warehouse_edit"
        createRole="warehouse_create" />
</template>
