<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  icon: { type: String, default: "💡" },
  color: { type: String }
})

const customColor = computed(() => {
  if (!props.color) {
    return undefined
  }

  const colors: Record<string, string> = {
    "red": "base08",
    "orange": "base09",
    "yellow": "base0a",
    "green": "base0b",
    "cyan": "base0c",
    "blue": "base0d",
    "purple": "base0e",
    "brown": "base0f"
  }

  const color = props.color.match(/base0\p{Hex_Digit}/) ? props.color : colors[props.color]
  return `background: hsl(var(--${color}-hsl) / 0.25); border-color: hsl(var(--${color}-hsl) / 0.75)`
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
