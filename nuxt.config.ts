// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  css: [
    '~/assets/style.styl',
  ],
  app: {
    head: {
      link: [
        { rel: 'manifest', href: '/manifest.webmanifest'},
        { rel: 'stylesheet', href: 'https://use.typekit.net/fln1ury.css' },
        { rel: 'icon', href: '/favicon.ico', sizes: 'any' },
        { rel: 'icon', href: '/favicon.svg', type: 'image/svg+xml' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png'}
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
  ]
})
