<template>
  <nav id="navigation">
    <ul>
      <li>
        <NuxtLink to="/" class="logo">Jeff Sandberg</NuxtLink>
      </li>
      <li>
        <NuxtLink to="/">Blog</NuxtLink>
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
nav
  border: 1px solid var(--base02)
  overflow: hidden
  border-radius: 10px
  width: var(--content-width)

ul
  all: unset
  display: flex
  flex-direction: row
  list-style-type: none
  gap: 20px
  align-items: center

li
  padding: 5px 0

a:not(.logo)
  all: unset
  cursor: pointer
  position relative
  font-size: 1.2rem
  font-family: var(--font-header)
  font-weight: 400;
  font-style: normal;

  &::after
    content: ''
    border-radius: 50%
    background: var(--base02)
    width: 5px
    height: 5px
    position absolute
    bottom: -8px
    left: 50%
    transform: translateY(calc(3em + 10px))
    transition: transform 0.2s ease-in-out

  &:hover::after
    transform: translateX(-50%)

.logo
  all: unset
  cursor: pointer
  border-right: 1px solid var(--base02)
  padding: 10px 15px
  font-size: 2rem

  font-family: var(--font-header)
  font-weight: 700
  font-style: italic
</style>
