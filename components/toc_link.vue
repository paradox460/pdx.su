<script setup lang="ts">
import { Ref, computed, ComputedRef } from "vue"

const props = defineProps({
  links: { type: Object, default: [] }
})


const onClick = async (id: string) => {
  if (document.getElementById(id)) {
    await navigateTo({ hash: `#${id}` })
  }
}

const activeToc = inject('activeToc') as ComputedRef<Ref<Set<string>>>

const isIntersecting = (id: string) => {
  return activeToc.value.value.has(id)
}
</script>

<template>
  <ul>
    <li v-for="{ id, text, children } in links" :id="`toc-${id}`" :key="id" @click="onClick(id)"
      :data-active="isIntersecting(id)">
      {{ text }}
      <TocLink v-if="children" :links="children" />
    </li>
  </ul>
</template>
