<script setup lang="ts">
import { Ref, computed, ComputedRef } from "vue"

const props = defineProps({
  links: { type: Object, default: [] }
})


const onClick = async (id: string, event: Event) => {
  event.preventDefault();
  const elem = document.getElementById(id)
  if (elem) {
    await navigateTo({ hash: `#${id}` })
    highlightCurrent(elem);
  }
}

const highlightCurrent = (target: HTMLElement) => {
  target.addEventListener('animationend', function removeActive() {
    delete target.dataset.active
    this.removeEventListener('animationend', removeActive)
  })
  target.dataset.active = ''
}

const activeToc = inject('activeToc') as ComputedRef<Ref<Set<string>>>

const isIntersecting = (id: string) => {
  return activeToc.value.value.has(id)
}
</script>

<template>
  <ul>
    <li v-for="{ id, text, children } in links" :id="`toc-${id}`" :key="id" :data-active="isIntersecting(id)">
      <a :href="`#${id}`" @click="onClick(id, $event)">{{ text }}</a>
      <TocLink v-if="children" :links="children" />
    </li>
  </ul>
</template>

<style lang="stylus">
@keyframes flash
  0%
    color: inherit
  50%
    color: var(--base0d)


:is(h1, h2, h3, h4, h5, h6)[data-active]
  animation: flash 0.75s 3 ease-in-out both
</style>
