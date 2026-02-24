class SitemapsController < ActionController::Base
  SITEMAP_XML = <<~XML.freeze
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>https://pokeapi.ekrem.dev/</loc>
      </url>
      <url>
        <loc>https://pokeapi.ekrem.dev/api/v2</loc>
      </url>
      <url>
        <loc>https://pokeapi.ekrem.dev/api/v3</loc>
      </url>
    </urlset>
  XML

  def show
    render plain: SITEMAP_XML, content_type: "application/xml; charset=utf-8"
  end
end
