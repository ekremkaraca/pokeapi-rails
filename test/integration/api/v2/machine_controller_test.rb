require "test_helper"

class Api::V2::MachineControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMachine.delete_all

    [
      { machine_number: 0, version_group_id: 20, item_id: 1288, move_id: 5 },
      { machine_number: 1, version_group_id: 20, item_id: 1164, move_id: 13 },
      { machine_number: 2, version_group_id: 20, item_id: 1165, move_id: 14 }
    ].each do |attrs|
      PokeMachine.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/machine", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_equal [ "url" ], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/machine/\d+/$}, payload["results"].first["url"])
  end

  test "show supports retrieval by id" do
    machine = PokeMachine.first

    get "/api/v2/machine/#{machine.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal machine.id, payload["id"]
    assert_equal machine.machine_number, payload["machine_number"]
    assert_equal machine.move_id, payload["move_id"]
  end

  test "show query count stays within budget" do
    machine = PokeMachine.first

    query_count = capture_select_query_count do
      get "/api/v2/machine/#{machine.id}"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/machine/abc"

    assert_response :not_found
  end
end
