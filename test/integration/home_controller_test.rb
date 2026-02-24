require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "renders root api explorer page" do
    get "/"

    assert_response :success
    assert_select "[data-controller~='api-explorer']"
    assert_select "h1", text: "Explore Pokemon Data Fast"
    assert_select "a[href='/api/v2/']", text: "API v2 Root"
    assert_select "a[href='/api/v3/']", text: "API v3 Root"
    assert_select "button", text: "Fetch JSON"
    assert_select "label", text: /View raw JSON/
    assert_select "h2", text: "Recent Requests"
    assert_select "h3", text: "Quick Notes"
    assert_select "h4", text: "v2"
    assert_select "h4", text: "v3"
  end
end
