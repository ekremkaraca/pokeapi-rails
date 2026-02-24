class HomeController < ApplicationController
  SAMPLE_PATHS = {
    "v2" => [
      "pokemon/ditto",
      "pokemon-species/aegislash",
      "type/3",
      "ability/battle-armor",
      "pokemon?limit=20&offset=0"
    ],
    "v3" => [
      "pokemon/1",
      "pokemon-species/1",
      "type/3",
      "ability/1",
      "pokemon?limit=20&offset=0"
    ]
  }.freeze

  def index
    @sample_paths = SAMPLE_PATHS
    render :index, formats: :html
  end
end
