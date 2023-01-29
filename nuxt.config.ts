// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
  css: [
    '~/assets/style.styl',
  ],
  app: {
    head: {
      link: [
        { rel: 'stylesheet', href: 'https://use.typekit.net/fln1ury.css' }
      ]
    }
  },
  content: {
    highlight: {
      theme: 'css-variables'
    }
  },
  modules: [
    '@vueuse/nuxt',
    '@nuxt/content'
  ]
})
