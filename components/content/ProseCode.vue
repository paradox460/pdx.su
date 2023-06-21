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
  <div class="codeblock" :class="{hasFilename: filename}">
    <div class="filename" v-if="filename">{{ filename }}</div>
    <slot />
    <a class="copybutton" title="copy" @click="copyCode">
      <svg class="icon" viewBox="0 0 24 24">
        <use xlink:href="#copy" />
      </svg>
    </a>
  </div>
</template>

<style lang="stylus">
.codeblock pre
  border: 1px solid var(--base02)
  padding: 1em 0.75em
  border-radius: 5px
  overflow-x: auto

pre code .line
  display: block
  min-height: 1.2em

pre code .highlight
  background: var(--base01)
</style>

<style lang="stylus" scoped>
.codeblock
  position relative
  margin-block-start: 1rem
  margin-block-end: 1rem

.copybutton
  position: absolute
  top: 0.5em
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


.filename
  position: absolute
  top calc(-2em + 2px)
  left: 10px
  border: 1px solid var(--base02)
  border-bottom: 0
  padding: 3px 8px
  border-radius: var(--radius)
  border-bottom-left-radius: 0
  border-bottom-right-radius: 0
  background: var(--background)

.hasFilename
  margin-block-start: calc(1rem + 1.2em)
</style>
