<template>
  <ContentList path="/_blog">
    <template v-slot="{ list }">
      <article v-for="article in list" :key="article._path">
        <a :href="article._path">
          <h1>{{ article.title }}</h1>
        </a>
        <p>{{ article.description }}</p>
      </article>
    </template>
  </ContentList>
</template>
