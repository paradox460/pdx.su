import { serverQueryContent } from "#content/server"
import RSS from "rss"

export default defineEventHandler(async (event) => {
  const posts = await serverQueryContent(event, "/blog").sort({ date: -1}).where({_partial: false}).find()

  const feed = new RSS({
    title: "Jeff Sandberg's Blog",
    site_url: "https://pdx.su",
    feed_url: "https://pdx.su/rss.xml"
  })

  for (const post of posts) {
    feed.item({
      title: post.title ?? '-',
      url: new URL(post?._path ?? '', 'https://pdx.su').toString(),
      date: post?.date,
      description: post?.description,
    })
  }

  event.node.res.setHeader('content-type', 'text/xml')
  event.node.res.end(feed.xml())
});
