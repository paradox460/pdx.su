<template>
  <nav>
    <ul>
      <li>
        <NuxtLink to="/">Home</NuxtLink>
      </li>
      <ContentNavigation v-slot="{ navigation }">
        <li v-for="link of navigation" :key="link._path">
          <NuxtLink :to="link._path">{{ link.title }}</NuxtLink>
        </li>
      </ContentNavigation>
    </ul>
  </nav>
</template>

<style lang="stylus" scoped>
nav ul
  all: unset
  display: flex
  flex-direction: row
  list-style-type: none
  gap: 10px
  margin: 0

  background-color: var(--base01)
  padding: 10px
  border-radius: 5px

  font-size: 1.5rem

  li
    box-sizing: border-box

a
  color: var(--base07)
  text-decoration: none
  display block
  padding: 5px 10px
  border-radius: 5px
  box-sizing: border-box
  transition: background 0.2s ease-in-out

  &:where(.router-link-active)
    background-color: var(--base00)


  &:hover
    background-color: var(--base02)
</style>
