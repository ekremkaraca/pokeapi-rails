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
        "pokemon?limit=20&include=abilities",
        "ability?limit=20&include=pokemon",
        "pokemon-species?limit=20&include=generation",
        "type?limit=20&include=pokemon",
        "move?limit=20&include=pokemon",
        "item?limit=20&include=category",
        "item-pocket?limit=20&include=item_categories",
        "item-attribute?limit=20&include=items",
        "item-fling-effect?limit=20&include=items",
        "language?limit=20",
        "location?limit=20&include=region",
        "location-area?limit=20&include=location",
        "machine?limit=20&include=item",
        "move-ailment?limit=20",
        "move-battle-style?limit=20",
        "move-category?limit=20",
        "move-damage-class?limit=20",
        "move-learn-method?limit=20",
        "move-target?limit=20",
        "characteristic?limit=20",
        "stat?limit=20",
        "super-contest-effect?limit=20",
        "pal-park-area?limit=20",
        "pokeathlon-stat?limit=20",
        "pokedex?limit=20",
        "pokemon-color?limit=20",
        "pokemon-form?limit=20",
        "pokemon-habitat?limit=20",
        "pokemon-shape?limit=20"
      ]
    }
  end
end
