require "test_helper"

class NotFoundFallbackTest < ActionDispatch::IntegrationTest
  test "returns lightweight plain-text 404 for unknown get paths" do
    get "/.git/config"

    assert_response :not_found
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]
    assert_match(/\Ano-cache|no-store\z/, response.headers["Cache-Control"].to_s)
    assert_equal "Not Found\n", response.body
    assert_operator response.body.bytesize, :<=, 16
  end

  test "returns lightweight plain-text 404 for unknown post paths" do
    post "/graphql", params: { query: "{ __typename }" }

    assert_response :not_found
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]
    assert_match(/\Ano-cache|no-store\z/, response.headers["Cache-Control"].to_s)
    assert_equal "Not Found\n", response.body
    assert_operator response.body.bytesize, :<=, 16
  end
end
