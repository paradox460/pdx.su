import { serverQueryContent } from "#content/server";
import { SitemapStream, streamToPromise } from 'sitemap';

export default defineEventHandler(async (event) => {

  const config = useRuntimeConfig()

  const docs = await serverQueryContent(event).where({_partial: false}).find()

  const sitemap = new SitemapStream({
    hostname: config.app.baseURL
  })

  for (const doc of docs) {
    sitemap.write({
      url: doc._path,
      changefreq: 'weekly',
    })
  }

  sitemap.end()

  return streamToPromise(sitemap)
})
