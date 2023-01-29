<script setup lang="ts">

const props = defineProps({
  links: { type: Object, default: [] }
})


const onClick = async (id: string) => {
  if (document.getElementById(id)) {
    await navigateTo({ hash: `#${id}`})
  }
}

const activeToc = inject('activeToc')
</script>

<template>
  <ul>
    <li v-for="{ id, text, children } in links" :id="`toc-${id}`" :key="id" @click="onClick(id)" :data-active="activeToc === id || null" >
      {{ text }}
      <TocLink v-if="children" :links="children" />
    </li>
  </ul>
</template>
