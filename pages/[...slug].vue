<template>
  <ContentDoc>
    <template #default="{ doc }">
      <TableOfContents :activeToc="activeToc" :doc="doc" />
      <div id="content" class="post">
        <ContentRenderer ref="nuxtContent" :value="doc" />
        <footer class="articlefooter" v-if="doc._path.match(/^\/blog/)">
          The article "{{ doc.title }}" was written on
          <Timestamp :datetime="doc.date" />
          <span v-if="doc.updated">, and updated on <Timestamp :datetime="doc.updated" /></span>
        </footer>
      </div>
    </template>
    <template #not-found>
      <div id="content" class="post errorpage">
        <h1>404 not found</h1>
        <p>The content you're looking for does not exist. Check the URL, or return to the <NuxtLink to="/">homepage</NuxtLink></p>
      </div>
    </template>
  </ContentDoc>
</template>

<style lang="stylus" scoped>
.articlefooter
  margin-top 3rem
  text-align center
  border: 1px solid var(--base01)
  border-radius: 5px
  padding: 0.5rem
  color: var(--base05)
</style>

<script setup lang="ts">
import { Ref } from "vue"

const activeToc = ref()
const nuxtContext = ref()

const observer: Ref<IntersectionObserver | null | undefined> = ref()
const observerOptions = reactive({
  root: nuxtContext.value,
  threshold: 1
})

onMounted(() => {
  observer.value = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (window.scrollY <= 0) {
        activeToc.value = null;
      }
      else if (entry.isIntersecting) {
        activeToc.value = entry.target.getAttribute("id")
      }
    })
  }, observerOptions)

  document.querySelectorAll('#content :is(h2, h3)[id]').forEach((el) => {
    observer.value?.observe((el))
  })
})

onUnmounted(() => {
  observer.value?.disconnect()
})
</script>
