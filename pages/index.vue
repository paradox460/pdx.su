<script setup lang="ts">
import type { QueryBuilderParams } from '@nuxt/content/dist/runtime/types';
const query: QueryBuilderParams = {
  path: "/_blog",
  sort: { date: -1 }
}
</script>
<template>
  <div id="content">
    <ContentList :query="query">
      <template v-slot="{ list }">
        <article v-for="article in list" :key="article._path">
          <header>
            <a :href="article._path">
              <h1>{{ article.title }}</h1>
            </a>
            <Timestamp :datetime="article.date" />
          </header>
          <div class="post">{{ article.description }}</div>
        </article>
      </template>
    </ContentList>
  </div>
</template>

<style lang="stylus">
article
  margin-bottom 1.5rem

article > header
  margin-bottom 1rem
  display: flex
  flex-direction: row
  align-items: baseline
  justify-content: space-between

  a
    all: unset
    color: var(--foreground)
    cursor: pointer

  h1
    all: unset
    font-size: 2rem
    font-weight: 700
    font-family: var(--font-header)

</style>
