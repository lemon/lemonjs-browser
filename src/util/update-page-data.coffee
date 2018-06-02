
###
# Check the current route and update window.page data
###

lemon.updatePageData = ->
  {hash, href, query, pathname} = lemon.checkRoute '*'
  page.data = site.data[pathname]
  page.hash = hash
  page.href = href
  page.markdown = site.markdown[pathname]
  page.pathname = pathname
  page.query = query
