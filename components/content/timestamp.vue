<template>
  <time v-if="!!t" :datetime="t" :title="fullTimeStamp">{{ niceTimeStamp }}</time>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{ t?: string, timestamp?: boolean, hoverTimestamp?: boolean }>();

let language = ref("en-US")

onMounted(() => {
  language.value = navigator.language;
})

const niceTimeStamp = computed(() => {
  if (props.t) {
    return (new Intl.DateTimeFormat(language.value, { dateStyle: "short", timeStyle: props.timestamp ? "short" : undefined }).format(Date.parse(props.t)));
  }
})

const fullTimeStamp = computed(() => {
  if (props.t) {
    return (new Intl.DateTimeFormat(language.value, { dateStyle: "full", timeStyle: (props.hoverTimestamp || props.timestamp) ? "full" : undefined }).format(Date.parse(props.t)));
  }
})

</script>

<style scoped lang="scss">
time {
  cursor: help;

  &:hover {
    text-decoration: underline wavy
  }
}
</style>
