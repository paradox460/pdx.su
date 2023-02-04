<script setup lang="ts">
import { closetag } from "sitemap/dist/lib/sitemap-stream";
import { Ref, computed } from "vue"

const props = defineProps({
  doc: { type: Object }
})

const tocLinks = computed(() => props.doc?.body.toc.links ?? [])

const activeToc = ref(new Set<string>())

provide('activeToc', computed(() => activeToc))

const observer: Ref<IntersectionObserver | null | undefined> = ref()

const isVisible = (id: string) => {
  return (document.getElementById(id)?.getBoundingClientRect()?.top ?? 0) >= 0
}

const headersSelector = '#content :is(h2, h3)[id]'

const findClosestOffscrenHeader = () => {
  const headers = [...document.querySelectorAll(headersSelector)]
  const { closestHeader } = headers.reduce<{ top: number, closestHeader?: Element }>((acc, header) => {
    const { top, closestHeader } = acc;

    const currentTop = header.getBoundingClientRect().top
    if (currentTop >= 0) {
      return acc
    }

    if (currentTop >= top) {
      return {
        top: currentTop,
        closestHeader: header
      }
    }
    return acc
  }, { top: -Infinity, closestHeader: undefined })

  return closestHeader
}

onMounted(() => {
  observer.value = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        // If an entry is intersecting
        // Add it to the registry
        activeToc.value.add(entry.target.id)
      } else {
        // If the entry is no longer intersecting
        // delete it from the registry
        activeToc.value.delete(entry.target.id)
        // And remove any old entries that are no longer intersecting
        for (const oldId of activeToc.value) {
          if (!isVisible(oldId)) {
            activeToc.value.delete(oldId)
          }
        }
        // If we have nothing in the registry, add the nearest header
        if (activeToc.value.size == 0) {
          const closest = findClosestOffscrenHeader()?.id;
          if (closest) { activeToc.value.add(closest) }
        }
      }
    })
  }, { threshold: 1, rootMargin: '10px'})

  document.querySelectorAll(headersSelector).forEach((el) => {
    observer.value?.observe((el))
  })
})

onUnmounted(() => {
  observer.value?.disconnect()
})
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
    transition: color 0.2s ease-in-out

    &[data-active=true], &:hover
      color: var(--foreground)

  & > ul
    position: sticky
    top: 2rem
    margin-top: 5rem
</style>
