<script setup lang="ts">
interface Props {
  code?: string
  language?: string
  filename?: string
  highlights?: Array<number>
  meta?: string
}

const props = withDefaults(defineProps<Props>(), {
  code: '',
  highlights: () => new Array<number>(),
})

function copyCode() {
  navigator.clipboard.writeText(props.code)
}
</script>

<template>
  <div class="codeblock">
    <div class="filename" v-if="filename">{{ filename }}</div>
    <slot />
    <a class="copybutton" title="copy" @click="copyCode">
      <svg class="icon" viewBox="0 0 24 24">
        <use xlink:href="#copy" />
      </svg>
    </a>
  </div>
</template>

<style lang="scss">
.codeblock pre {
  padding: 1.5em 2em;
  overflow-x: auto
}

pre code .line {
  display: block;
  min-height: 1.2em;
}

pre code .highlight {
  background: var(--base01);
}
</style>

<style lang="scss" scoped>
.codeblock {
  position: relative;
  margin-block-start: 1rem;
  margin-block-end: 1rem;
  border: 1px solid var(--base02);
  border-radius: var(--radius);
}

.copybutton {
  position: absolute;
  top: 0.5em;
  right: 10px;
  width: 1em;
  height: 1em;
  padding: 5px;
  border: 1px solid var(--base02);
  background: var(--base01);
  border-radius: 5px;
  cursor: pointer;
  display: none;
}

.codeblock:has(.filename) .copybutton {
  top: 3rem
}


.icon {
  fill: var(--foreground);
}

.codeblock:hover .copybutton {
  display: block;
}


.filename {
  border-bottom: 1px solid var(--base02);
  padding: 0.5rem 1rem;
}
</style>
