<template>
  <time v-if="!!datetime" :datetime="datetime">{{ niceTimeStamp }}</time>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{ datetime?: string }>();

let language = ref("en-US")

onMounted(() => {
  language.value = navigator.language;
})

const niceTimeStamp = computed(() => {
  if (props.datetime) {
    return (new Intl.DateTimeFormat(language.value, { dateStyle: "short", timeStyle: undefined }).format(Date.parse(props.datetime)));
  }
})

</script>
