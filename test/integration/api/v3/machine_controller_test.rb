require "test_helper"

class Api::V3::MachineControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMachine.delete_all
    PokeMove.delete_all
    PokeItem.delete_all
    PokeVersionGroup.delete_all

    version_group = PokeVersionGroup.create!(name: "red-blue", sort_order: 1, generation_id: 1)
    move = PokeMove.create!(name: "thunderbolt", accuracy: 100, power: 90, pp: 15, priority: 0, type_id: 13, damage_class_id: 3, target_id: 10)
    item_one = PokeItem.create!(name: "tm24", cost: 3000, category_id: 1)
    item_two = PokeItem.create!(name: "tm25", cost: 3000, category_id: 1)
    item_three = PokeItem.create!(name: "tm26", cost: 3000, category_id: 1)

    [
      { machine_number: 24, version_group_id: version_group.id, item_id: item_one.id, move_id: move.id },
      { machine_number: 25, version_group_id: version_group.id, item_id: item_two.id, move_id: move.id },
      { machine_number: 26, version_group_id: version_group.id, item_id: item_three.id, move_id: move.id }
    ].each do |attrs|
      PokeMachine.create!(attrs)
    end
  end

  test "list returns paginated summary data with id and url" do
    get "/api/v3/machine", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id item_id machine_number move_id name url version_group_id], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/machine/\d+/$}, payload["results"].first["url"])
    assert_match(/\Amachine-\d+\z/, payload["results"].first["name"])
  end

  test "list supports q filter over synthetic name" do
    machine = PokeMachine.order(:id).first
    get "/api/v3/machine", params: { q: machine.id.to_s }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal machine.id, payload.dig("results", 0, "id")
  end

  test "list supports filter by synthetic name" do
    machine = PokeMachine.order(:id).second
    get "/api/v3/machine", params: { filter: { name: "machine-#{machine.id}" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal machine.id, payload.dig("results", 0, "id")
  end

  test "list combines q and filter with and semantics" do
    machine = PokeMachine.order(:id).second
    get "/api/v3/machine", params: { q: machine.id.to_s, filter: { name: "machine-#{machine.id}" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal machine.id, payload.dig("results", 0, "id")
  end

  test "list supports sort parameter" do
    get "/api/v3/machine", params: { sort: "-machine_number" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 26, payload.fetch("results").first.fetch("machine_number")
  end

  test "list supports fields filter" do
    get "/api/v3/machine", params: { limit: 1, fields: "name,url,machine_number" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[machine_number name url], payload["results"].first.keys.sort
  end

  test "list supports include item" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine", params: { filter: { name: "machine-#{machine.id}" }, include: "item" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal machine.id, result["id"]
    assert_match(%r{\Atm\d+\z}, result.dig("item", "name"))
    assert_match(%r{/api/v3/item/\d+/$}, result.dig("item", "url"))
  end

  test "show returns machine payload with standardized keys" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine/#{machine.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id item_id machine_number move_id name url version_group_id], payload.keys.sort
    assert_equal machine.id, payload["id"]
    assert_equal machine.machine_number, payload["machine_number"]
    assert_match(%r{/api/v3/machine/#{machine.id}/$}, payload["url"])
  end

  test "show supports include item" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine/#{machine.id}", params: { include: "item" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_match(%r{\Atm\d+\z}, payload.dig("item", "name"))
    assert_match(%r{/api/v3/item/\d+/$}, payload.dig("item", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/machine/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/machine", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/machine", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/machine", params: { sort: "move_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["move_id"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/machine", params: { filter: { machine_number: "24" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["machine_number"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine/"
    assert_response :success

    get "/api/v3/machine/#{machine.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    machine = PokeMachine.order(:id).first
    get "/api/v3/machine", params: { limit: 2, offset: 0, q: machine.id.to_s }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/machine", params: { limit: 2, offset: 0, q: machine.id.to_s }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine/#{machine.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/machine/#{machine.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    machine = PokeMachine.order(:id).first
    get "/api/v3/machine", params: { q: machine.id.to_s }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/machine", params: { q: machine.id.to_s, include: "item" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    machine = PokeMachine.order(:id).first

    get "/api/v3/machine/#{machine.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/machine/#{machine.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
