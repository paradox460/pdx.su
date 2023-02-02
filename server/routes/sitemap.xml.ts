import { serverQueryContent } from "#content/server";
import { SitemapStream, streamToPromise } from 'sitemap';

function determineBaseUrl() {
  const site_url = "https://pdx.su";
  const config = useRuntimeConfig();
  const url = config.app.baseURL || site_url;

  return url === "/" ? site_url : url
}

export default defineEventHandler(async (event) => {
  const docs = await serverQueryContent(event).where({ _partial: false }).find()

  const sitemap = new SitemapStream({
    hostname: determineBaseUrl()
  })

  for (const doc of docs) {
    sitemap.write({
      url: doc._path,
      changefreq: 'weekly',
    })
  }

  sitemap.end()

  event.node.res.setHeader('Content-Type', 'application/xml')
  event.node.res.end(await streamToPromise(sitemap))
})
