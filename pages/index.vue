<script setup lang="ts">
import type { QueryBuilderParams } from '@nuxt/content/dist/runtime/types';
const query: QueryBuilderParams = {
  path: "/blog",
  sort: { date: -1 }
}

const title = "Jeff Sandberg's Blog"
const description = "The personal blog of software engineer Jeff Sandberg. Mostly tech, but not always."
const url = "https://pdx.su"

useHead({
  title: title,
  meta: [
    { property: "og:type", content: "website" },
    { property: "og:title", content: title },
    { property: "og:description", content: description },
    { property: "og:image", content: `${url}/favicon.svg` },
    { property: "og:url", content: url },
    { property: "twitter:card", content: "summary" },
    { property: "twitter:title", content: title },
    { property: "twitter:description", content: description }
  ],
  link: [
    { rel: 'canonical', href: url }
  ]
})
</script>
<template>
  <div id="content">
    <ContentList :query="query">
      <template v-slot="{ list }">
        <article v-for="article in list" :key="article._path" :class="{ draft: article.draft }">
          <NuxtLink :to="article._path" class="postlink">
            <header class="postheader">
              <h1>{{ article.title }}</h1>
              <div class="timestamp">
                <span class="published">Published </span>
                <Timestamp :t="article.date" /></div>
            </header>
            <div class="post">{{ article.description }}</div>
          </NuxtLink>
        </article>
      </template>
    </ContentList>
  </div>
</template>

<style lang="scss" scoped>
article {
  margin-bottom: 1.5rem
}

.postlink {
  all: unset;
  color: var(--foreground);
  cursor: pointer
}

.postheader {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: row;
  gap: 1rem;
  align-items: baseline;
  justify-content: space-between;

  @media (max-width: 500px) {
    flex-direction: column;
  }

  h1 {
    all: unset;
    font-size: 2rem;
    font-weight: 700;
    font-family: var(--font-header)
  }

  .timestamp {
    font-style: italic;
    color: color-mix(in srgb, var(--foreground) 50%, transparent);
  }
  .published {
    display: none;

    @media (max-width: 500px) {
      display: inline;
    }
  }
}


</style>
