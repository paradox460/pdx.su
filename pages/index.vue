<script setup lang="ts">
import type { QueryBuilderParams } from '@nuxt/content/dist/runtime/types';
const query: QueryBuilderParams = {
  path: "/blog",
  sort: { date: -1 }
}
</script>
<template>
  <div id="content">
    <ContentList :query="query">
      <template v-slot="{ list }">
        <article v-for="article in list" :key="article._path" :class="{ draft: article.draft }">
          <NuxtLink :to="article._path" class="postlink">
            <header class="postheader">
              <h1>{{ article.title }}</h1>
              <Timestamp :datetime="article.date" />
            </header>
            <div class="post">{{ article.description }}</div>
          </NuxtLink>
        </article>
      </template>
    </ContentList>
  </div>
</template>

<style lang="stylus" scoped>
article
  margin-bottom 1.5rem

.postlink
  all: unset
  color: var(--foreground)
  cursor: pointer

.postheader
  margin-bottom 1rem
  display: flex
  flex-direction: row
  align-items: baseline
  justify-content: space-between

  h1
    all: unset
    font-size: 2rem
    font-weight: 700
    font-family: var(--font-header)

</style>
