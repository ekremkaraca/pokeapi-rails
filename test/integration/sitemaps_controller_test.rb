require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "serves sitemap xml" do
    get "/sitemap.xml"

    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.headers["Content-Type"]

    body = response.body
    assert_includes body, "<urlset"
    assert_includes body, "<loc>https://pokeapi.ekrem.dev/</loc>"
    assert_includes body, "<loc>https://pokeapi.ekrem.dev/api/v2</loc>"
    assert_includes body, "<loc>https://pokeapi.ekrem.dev/api/v3</loc>"
  end
end
