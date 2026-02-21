class HomeController < ApplicationController
  def index
    @sample_paths = {
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
    }
  end
end
