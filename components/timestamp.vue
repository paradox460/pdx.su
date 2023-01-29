<template>
  <time v-if="!!datetime" :datetime="datetime">{{ niceTimeStamp }}</time>
</template>

<script setup lang="ts">
const props = defineProps<{datetime?: string }>();

let language = "us"

onMounted(() => {
  language = navigator.language;
})

const niceTimeStamp = computed(() => {
  if (props.datetime) {
    return (new Intl.DateTimeFormat(language, { dateStyle: "short", timeStyle: undefined}).format(Date.parse(props.datetime)));
  }
})

</script>
