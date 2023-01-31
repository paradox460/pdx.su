// https://v3.nuxtjs.org/api/configuration/nuxt.config
const title = "Jeff Sandberg's Blog"
const description = "The personal blog of software engineer Jeff Sandberg. Mostly tech, but not always."

export default defineNuxtConfig({
  css: [
    '~/assets/style.styl',
  ],
  app: {
    head: {
      title: title,
      htmlAttrs: {
        lang: 'en'
      },
      meta: [
        // Color for ux
        { name: "theme-color", media: "(prefers-color-scheme: light)", content: "#ffffff" },
        { name: "theme-color", media: "(prefers-color-scheme: dark)", content: "#1d1f21" },
        // Description
        { name: "description", content: description },

        // OpenGraph stuff
        { property: 'og:locale', content: "en_US" },

        // Twitter stuff
        { property: "twitter:site", content: "@paradox460" },
      ],

      link: [
        // icons
        { rel: 'manifest', href: '/manifest.webmanifest' },
        { rel: 'icon', href: '/favicon.ico', sizes: 'any' },
        { rel: 'icon', href: '/favicon.svg', type: 'image/svg+xml' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
        // Stylesheets
        { rel: 'stylesheet', href: 'https://use.typekit.net/fln1ury.css' },
        // RSS
        { rel: 'alternate', type: 'application/rss+xml', href: '/rss.xml' },
      ]
    }
  },
  content: {
    highlight: {
      theme: 'css-variables'
    }
  },
  modules: [
    '@nuxt/content'
  ],
  nitro: {
    prerender: {
      routes: ['/rss.xml']
    }
  }
})
