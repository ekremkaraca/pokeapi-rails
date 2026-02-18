Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Redirect root path to API v2 root endpoint.
  root to: redirect("/api/v2/")

  namespace :api do
    namespace :v2 do
      get "(/)", to: "root#index", as: :root

      get "ability(/)", to: "ability#index", as: :ability_index
      get "ability/:id(/)", to: "ability#show", as: :ability
      get "berry(/)", to: "berry#index", as: :berry_index
      get "berry/:id(/)", to: "berry#show", as: :berry
      get "berry-firmness(/)", to: "berry_firmness#index", as: :berry_firmness_index
      get "berry-firmness/:id(/)", to: "berry_firmness#show", as: :berry_firmness
      get "berry-flavor(/)", to: "berry_flavor#index", as: :berry_flavor_index
      get "berry-flavor/:id(/)", to: "berry_flavor#show", as: :berry_flavor
      get "characteristic(/)", to: "characteristic#index", as: :characteristic_index
      get "characteristic/:id(/)", to: "characteristic#show", as: :characteristic
      get "contest-type(/)", to: "contest_type#index", as: :contest_type_index
      get "contest-type/:id(/)", to: "contest_type#show", as: :contest_type
      get "contest-effect(/)", to: "contest_effect#index", as: :contest_effect_index
      get "contest-effect/:id(/)", to: "contest_effect#show", as: :contest_effect
      get "evolution-chain(/)", to: "evolution_chain#index", as: :evolution_chain_index
      get "evolution-chain/:id(/)", to: "evolution_chain#show", as: :evolution_chain
      get "evolution-trigger(/)", to: "evolution_trigger#index", as: :evolution_trigger_index
      get "evolution-trigger/:id(/)", to: "evolution_trigger#show", as: :evolution_trigger
      get "encounter-method(/)", to: "encounter_method#index", as: :encounter_method_index
      get "encounter-method/:id(/)", to: "encounter_method#show", as: :encounter_method
      get "encounter-condition(/)", to: "encounter_condition#index", as: :encounter_condition_index
      get "encounter-condition/:id(/)", to: "encounter_condition#show", as: :encounter_condition
      get "egg-group(/)", to: "egg_group#index", as: :egg_group_index
      get "egg-group/:id(/)", to: "egg_group#show", as: :egg_group
      get "encounter-condition-value(/)", to: "encounter_condition_value#index", as: :encounter_condition_value_index
      get "encounter-condition-value/:id(/)", to: "encounter_condition_value#show", as: :encounter_condition_value
      get "generation(/)", to: "generation#index", as: :generation_index
      get "generation/:id(/)", to: "generation#show", as: :generation
      get "gender(/)", to: "gender#index", as: :gender_index
      get "gender/:id(/)", to: "gender#show", as: :gender
      get "growth-rate(/)", to: "growth_rate#index", as: :growth_rate_index
      get "growth-rate/:id(/)", to: "growth_rate#show", as: :growth_rate
      get "item(/)", to: "item#index", as: :item_index
      get "item/:id(/)", to: "item#show", as: :item
      get "item-attribute(/)", to: "item_attribute#index", as: :item_attribute_index
      get "item-attribute/:id(/)", to: "item_attribute#show", as: :item_attribute
      get "item-category(/)", to: "item_category#index", as: :item_category_index
      get "item-category/:id(/)", to: "item_category#show", as: :item_category
      get "item-fling-effect(/)", to: "item_fling_effect#index", as: :item_fling_effect_index
      get "item-fling-effect/:id(/)", to: "item_fling_effect#show", as: :item_fling_effect
      get "item-pocket(/)", to: "item_pocket#index", as: :item_pocket_index
      get "item-pocket/:id(/)", to: "item_pocket#show", as: :item_pocket
      get "language(/)", to: "language#index", as: :language_index
      get "language/:id(/)", to: "language#show", as: :language
      get "location(/)", to: "location#index", as: :location_index
      get "location/:id(/)", to: "location#show", as: :location
      get "location-area(/)", to: "location_area#index", as: :location_area_index
      get "location-area/:id(/)", to: "location_area#show", as: :location_area
      get "machine(/)", to: "machine#index", as: :machine_index
      get "machine/:id(/)", to: "machine#show", as: :machine
      get "move(/)", to: "move#index", as: :move_index
      get "move/:id(/)", to: "move#show", as: :move
      get "move-damage-class(/)", to: "move_damage_class#index", as: :move_damage_class_index
      get "move-damage-class/:id(/)", to: "move_damage_class#show", as: :move_damage_class
      get "move-ailment(/)", to: "move_ailment#index", as: :move_ailment_index
      get "move-ailment/:id(/)", to: "move_ailment#show", as: :move_ailment
      get "move-battle-style(/)", to: "move_battle_style#index", as: :move_battle_style_index
      get "move-battle-style/:id(/)", to: "move_battle_style#show", as: :move_battle_style
      get "move-category(/)", to: "move_category#index", as: :move_category_index
      get "move-category/:id(/)", to: "move_category#show", as: :move_category
      get "move-learn-method(/)", to: "move_learn_method#index", as: :move_learn_method_index
      get "move-learn-method/:id(/)", to: "move_learn_method#show", as: :move_learn_method
      get "move-target(/)", to: "move_target#index", as: :move_target_index
      get "move-target/:id(/)", to: "move_target#show", as: :move_target
      get "nature(/)", to: "nature#index", as: :nature_index
      get "nature/:id(/)", to: "nature#show", as: :nature
      get "pokedex(/)", to: "pokedex#index", as: :pokedex_index
      get "pokedex/:id(/)", to: "pokedex#show", as: :pokedex
      get "pokemon-color(/)", to: "pokemon_color#index", as: :pokemon_color_index
      get "pokemon-color/:id(/)", to: "pokemon_color#show", as: :pokemon_color
      get "pokemon-form(/)", to: "pokemon_form#index", as: :pokemon_form_index
      get "pokemon-form/:id(/)", to: "pokemon_form#show", as: :pokemon_form
      get "pokemon-habitat(/)", to: "pokemon_habitat#index", as: :pokemon_habitat_index
      get "pokemon-habitat/:id(/)", to: "pokemon_habitat#show", as: :pokemon_habitat
      get "pokemon-shape(/)", to: "pokemon_shape#index", as: :pokemon_shape_index
      get "pokemon-shape/:id(/)", to: "pokemon_shape#show", as: :pokemon_shape
      get "pokemon-species(/)", to: "pokemon_species#index", as: :pokemon_species_index
      get "pokemon-species/:id(/)", to: "pokemon_species#show", as: :pokemon_species
      get "pokeathlon-stat(/)", to: "pokeathlon_stat#index", as: :pokeathlon_stat_index
      get "pokeathlon-stat/:id(/)", to: "pokeathlon_stat#show", as: :pokeathlon_stat
      get "region(/)", to: "region#index", as: :region_index
      get "region/:id(/)", to: "region#show", as: :region
      get "stat(/)", to: "stat#index", as: :stat_index
      get "stat/:id(/)", to: "stat#show", as: :stat
      get "super-contest-effect(/)", to: "super_contest_effect#index", as: :super_contest_effect_index
      get "super-contest-effect/:id(/)", to: "super_contest_effect#show", as: :super_contest_effect
      get "type(/)", to: "type#index", as: :type_index
      get "type/:id(/)", to: "type#show", as: :type
      get "version(/)", to: "version#index", as: :version_index
      get "version/:id(/)", to: "version#show", as: :version
      get "version-group(/)", to: "version_group#index", as: :version_group_index
      get "version-group/:id(/)", to: "version_group#show", as: :version_group

      get "pokemon(/)", to: "pokemon#index", as: :pokemon_index
      get "pal-park-area(/)", to: "pal_park_area#index", as: :pal_park_area_index
      get "pal-park-area/:id(/)", to: "pal_park_area#show", as: :pal_park_area
      get "pokemon/:id/encounters(/)", to: "pokemon_encounters#show"
      get "pokemon/:id(/)", to: "pokemon#show", as: :pokemon
    end
  end

  if Rails.env.development?
    mount RailsPgExtras::Web::Engine, at: 'pg_extras'
  end
end
