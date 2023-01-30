<script setup lang="ts">
import { computed } from "vue"

const props = defineProps({
  activeToc: { type: String },
  doc: { type: Object }
})

const tocLinks = computed(() => props.doc?.body.toc.links ?? [])

provide('activeToc', computed(() => props.activeToc))

</script>

<template>
  <nav id="toc">
    <TocLink :links="tocLinks" />
  </nav>
</template>

<style lang="stylus">
#toc
  width: 256px
  font-size: 0.9rem

  & > ul
    position: sticky
    top: 2rem
    margin-top: 4rem

  ul
    list-style-type: none
    display: block
    margin: unset
    padding: unset

    ul
      margin-left: 2em

  li
    margin-bottom: 0.5em
    color: var(--base04)
    text-decoration none
    cursor: pointer
    transition: all 0.2s ease-in-out

    &[data-active=true], &:hover
      color: var(--foreground)


</style>
