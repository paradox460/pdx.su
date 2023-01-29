<script lang="ts">
import { defineComponent } from '#imports'

export default defineComponent({
  props: {
    code: {
      type: String,
      default: ''
    },
    language: {
      type: String,
      default: null
    },
    filename: {
      type: String,
      default: null
    },
    highlights: {
      type: Array as () => number[],
      default: () => []
    },
    meta: {
      type: String,
      default: null
    }
  },
  methods: {
    copyCode() {
      navigator.clipboard.writeText(this.code)
    }
  }
})
</script>

<template>
  <div class="codeblock">
    <slot />
    <a class="copybutton" title="copy" @click="copyCode">
      <svg class="icon" viewBox="0 0 24 24">
        <path d="M15 20H5V7c0-.55-.45-1-1-1s-1 .45-1 1v13c0 1.1.9 2 2 2h10c.55 0 1-.45 1-1s-.45-1-1-1zm5-4V4c0-1.1-.9-2-2-2H9c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h9c1.1 0 2-.9 2-2zm-2 0H9V4h9v12z"></path>
        </svg>
    </a>
  </div>
</template>

<style lang="stylus">
pre code .line
  display: block
  min-height: 1rem
</style>

<style lang="stylus" scoped>
.codeblock
  position relative
  margin-block-start: 1rem
  margin-block-end: 1rem

  border: 1px solid var(--base02)
  padding: 1em 0.5em
  border-radius: 5px


.copybutton
  position: absolute
  top: 10px
  right: 10px
  width 1em
  height 1em
  padding 5px
  border: 1px solid var(--base02)
  background: var(--base01)
  border-radius: 5px
  cursor pointer

  display: none

  .icon
    fill: var(--foreground)

.codeblock:hover .copybutton
  display: block

pre code .highlight
  background: var(--base01)
</style>
