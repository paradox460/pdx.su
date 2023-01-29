<template>
  <ContentDoc >
    <template #default="{ doc }">
      <TableOfContents :activeToc="activeToc" :doc="doc" />
      <ContentRenderer ref="nuxtContent" :value="doc" id="content" class="post"/>
    </template>
  </ContentDoc>
</template>

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
