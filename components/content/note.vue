<script setup>
import { computed } from 'vue'

const props = defineProps({
  icon: { type: String, default: "💡" },
  color: { type: String }
})


const customColor = computed(() => {
  if (!props.color) {
    return null
  }
  return `background: hsl(var(--${props.color}-hsl) / 0.25); border-color: hsl(var(--${props.color}-hsl) / 0.75)`
})
</script>

<template>
  <aside class="note" :style=customColor>
    <div class="icon">{{ icon }}</div>
    <div class="content">
      <slot />
    </div>
  </aside>
</template>

<style lang="stylus" scoped>
.note
  background: var(--base02)
  border: 1px solid var(--base03)
  border-radius: 5px
  display: grid
  grid-template-columns: 35px auto
  gap: 10px
  margin-block: 1em 0
  padding-left: 10px

.icon
  justify-self: center
  align-self: center
  font-size: 25px

</style>
