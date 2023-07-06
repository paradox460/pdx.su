<template>
  <time v-if="!!datetime" :datetime="datetime" :title="fullTimeStamp">{{ niceTimeStamp }}</time>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{ datetime?: string, timestamp?: boolean, hovertimestamp?: boolean }>();

let language = ref("en-US")

onMounted(() => {
  language.value = navigator.language;
})

const niceTimeStamp = computed(() => {
  if (props.datetime) {
    return (new Intl.DateTimeFormat(language.value, { dateStyle: "short", timeStyle: props.timestamp ? "short" : undefined }).format(Date.parse(props.datetime)));
  }
})

const fullTimeStamp = computed(() => {
  if (props.datetime) {
    return (new Intl.DateTimeFormat(language.value, { dateStyle: "full", timeStyle: props.hovertimestamp || props.timestamp ? "full" : undefined }).format(Date.parse(props.datetime)));
  }
})

</script>
