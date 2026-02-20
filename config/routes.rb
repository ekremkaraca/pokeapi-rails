# == Route Map
#
# Routes for application:
#                                   Prefix Verb URI Pattern                                                                                       Controller#Action
#                                 rswag_ui      /swagger                                                                                          Rswag::Ui::Engine
#                                rswag_api      /swagger                                                                                          Rswag::Api::Engine
#                                 api_docs GET  /api-docs(.:format)                                                                               redirect(301, /swagger)
#                                          GET  /api-docs/*path(.:format)                                                                         redirect(301, /swagger/%{path})
#                       rails_health_check GET  /up(.:format)                                                                                     rails/health#show
#                                     root GET  /                                                                                                 home#index
#                              api_v3_root GET  /api/v3(/)(.:format)                                                                              api/v3/root#index
#                     api_v3_pokemon_index GET  /api/v3/pokemon(.:format)                                                                         api/v3/pokemon#index
#                           api_v3_pokemon GET  /api/v3/pokemon/:id(.:format)                                                                     api/v3/pokemon#show
#                     api_v3_ability_index GET  /api/v3/ability(.:format)                                                                         api/v3/ability#index
#                           api_v3_ability GET  /api/v3/ability/:id(.:format)                                                                     api/v3/ability#show
#                        api_v3_type_index GET  /api/v3/type(.:format)                                                                            api/v3/type#index
#                              api_v3_type GET  /api/v3/type/:id(.:format)                                                                        api/v3/type#show
#                        api_v3_move_index GET  /api/v3/move(.:format)                                                                            api/v3/move#index
#                              api_v3_move GET  /api/v3/move/:id(.:format)                                                                        api/v3/move#show
#                        api_v3_item_index GET  /api/v3/item(.:format)                                                                            api/v3/item#index
#                              api_v3_item GET  /api/v3/item/:id(.:format)                                                                        api/v3/item#show
#                  api_v3_generation_index GET  /api/v3/generation(.:format)                                                                      api/v3/generation#index
#                        api_v3_generation GET  /api/v3/generation/:id(.:format)                                                                  api/v3/generation#show
#               api_v3_version_group_index GET  /api/v3/version-group(.:format)                                                                   api/v3/version_group#index
#                     api_v3_version_group GET  /api/v3/version-group/:id(.:format)                                                               api/v3/version_group#show
#                      api_v3_region_index GET  /api/v3/region(.:format)                                                                          api/v3/region#index
#                            api_v3_region GET  /api/v3/region/:id(.:format)                                                                      api/v3/region#show
#                     api_v3_version_index GET  /api/v3/version(.:format)                                                                         api/v3/version#index
#                           api_v3_version GET  /api/v3/version/:id(.:format)                                                                     api/v3/version#show
#             api_v3_evolution_chain_index GET  /api/v3/evolution-chain(.:format)                                                                 api/v3/evolution_chain#index
#                   api_v3_evolution_chain GET  /api/v3/evolution-chain/:id(.:format)                                                             api/v3/evolution_chain#show
#           api_v3_evolution_trigger_index GET  /api/v3/evolution-trigger(.:format)                                                               api/v3/evolution_trigger#index
#                 api_v3_evolution_trigger GET  /api/v3/evolution-trigger/:id(.:format)                                                           api/v3/evolution_trigger#show
#                 api_v3_growth_rate_index GET  /api/v3/growth-rate(.:format)                                                                     api/v3/growth_rate#index
#                       api_v3_growth_rate GET  /api/v3/growth-rate/:id(.:format)                                                                 api/v3/growth_rate#show
#                      api_v3_nature_index GET  /api/v3/nature(.:format)                                                                          api/v3/nature#index
#                            api_v3_nature GET  /api/v3/nature/:id(.:format)                                                                      api/v3/nature#show
#                      api_v3_gender_index GET  /api/v3/gender(.:format)                                                                          api/v3/gender#index
#                            api_v3_gender GET  /api/v3/gender/:id(.:format)                                                                      api/v3/gender#show
#                   api_v3_egg_group_index GET  /api/v3/egg-group(.:format)                                                                       api/v3/egg_group#index
#                         api_v3_egg_group GET  /api/v3/egg-group/:id(.:format)                                                                   api/v3/egg_group#show
#            api_v3_encounter_method_index GET  /api/v3/encounter-method(.:format)                                                                api/v3/encounter_method#index
#                  api_v3_encounter_method GET  /api/v3/encounter-method/:id(.:format)                                                            api/v3/encounter_method#show
#         api_v3_encounter_condition_index GET  /api/v3/encounter-condition(.:format)                                                             api/v3/encounter_condition#index
#               api_v3_encounter_condition GET  /api/v3/encounter-condition/:id(.:format)                                                         api/v3/encounter_condition#show
#   api_v3_encounter_condition_value_index GET  /api/v3/encounter-condition-value(.:format)                                                       api/v3/encounter_condition_value#index
#         api_v3_encounter_condition_value GET  /api/v3/encounter-condition-value/:id(.:format)                                                   api/v3/encounter_condition_value#show
#                       api_v3_berry_index GET  /api/v3/berry(.:format)                                                                           api/v3/berry#index
#                             api_v3_berry GET  /api/v3/berry/:id(.:format)                                                                       api/v3/berry#show
#              api_v3_berry_firmness_index GET  /api/v3/berry-firmness(.:format)                                                                  api/v3/berry_firmness#index
#                    api_v3_berry_firmness GET  /api/v3/berry-firmness/:id(.:format)                                                              api/v3/berry_firmness#show
#                api_v3_berry_flavor_index GET  /api/v3/berry-flavor(.:format)                                                                    api/v3/berry_flavor#index
#                      api_v3_berry_flavor GET  /api/v3/berry-flavor/:id(.:format)                                                                api/v3/berry_flavor#show
#                api_v3_contest_type_index GET  /api/v3/contest-type(.:format)                                                                    api/v3/contest_type#index
#                      api_v3_contest_type GET  /api/v3/contest-type/:id(.:format)                                                                api/v3/contest_type#show
#              api_v3_contest_effect_index GET  /api/v3/contest-effect(.:format)                                                                  api/v3/contest_effect#index
#                    api_v3_contest_effect GET  /api/v3/contest-effect/:id(.:format)                                                              api/v3/contest_effect#show
#               api_v3_item_category_index GET  /api/v3/item-category(.:format)                                                                   api/v3/item_category#index
#                     api_v3_item_category GET  /api/v3/item-category/:id(.:format)                                                               api/v3/item_category#show
#                 api_v3_item_pocket_index GET  /api/v3/item-pocket(.:format)                                                                     api/v3/item_pocket#index
#                       api_v3_item_pocket GET  /api/v3/item-pocket/:id(.:format)                                                                 api/v3/item_pocket#show
#              api_v3_item_attribute_index GET  /api/v3/item-attribute(.:format)                                                                  api/v3/item_attribute#index
#                    api_v3_item_attribute GET  /api/v3/item-attribute/:id(.:format)                                                              api/v3/item_attribute#show
#           api_v3_item_fling_effect_index GET  /api/v3/item-fling-effect(.:format)                                                               api/v3/item_fling_effect#index
#                 api_v3_item_fling_effect GET  /api/v3/item-fling-effect/:id(.:format)                                                           api/v3/item_fling_effect#show
#                    api_v3_language_index GET  /api/v3/language(.:format)                                                                        api/v3/language#index
#                          api_v3_language GET  /api/v3/language/:id(.:format)                                                                    api/v3/language#show
#                    api_v3_location_index GET  /api/v3/location(.:format)                                                                        api/v3/location#index
#                          api_v3_location GET  /api/v3/location/:id(.:format)                                                                    api/v3/location#show
#               api_v3_location_area_index GET  /api/v3/location-area(.:format)                                                                   api/v3/location_area#index
#                     api_v3_location_area GET  /api/v3/location-area/:id(.:format)                                                               api/v3/location_area#show
#                     api_v3_machine_index GET  /api/v3/machine(.:format)                                                                         api/v3/machine#index
#                           api_v3_machine GET  /api/v3/machine/:id(.:format)                                                                     api/v3/machine#show
#                api_v3_move_ailment_index GET  /api/v3/move-ailment(.:format)                                                                    api/v3/move_ailment#index
#                      api_v3_move_ailment GET  /api/v3/move-ailment/:id(.:format)                                                                api/v3/move_ailment#show
#           api_v3_move_battle_style_index GET  /api/v3/move-battle-style(.:format)                                                               api/v3/move_battle_style#index
#                 api_v3_move_battle_style GET  /api/v3/move-battle-style/:id(.:format)                                                           api/v3/move_battle_style#show
#               api_v3_move_category_index GET  /api/v3/move-category(.:format)                                                                   api/v3/move_category#index
#                     api_v3_move_category GET  /api/v3/move-category/:id(.:format)                                                               api/v3/move_category#show
#           api_v3_move_damage_class_index GET  /api/v3/move-damage-class(.:format)                                                               api/v3/move_damage_class#index
#                 api_v3_move_damage_class GET  /api/v3/move-damage-class/:id(.:format)                                                           api/v3/move_damage_class#show
#           api_v3_move_learn_method_index GET  /api/v3/move-learn-method(.:format)                                                               api/v3/move_learn_method#index
#                 api_v3_move_learn_method GET  /api/v3/move-learn-method/:id(.:format)                                                           api/v3/move_learn_method#show
#                 api_v3_move_target_index GET  /api/v3/move-target(.:format)                                                                     api/v3/move_target#index
#                       api_v3_move_target GET  /api/v3/move-target/:id(.:format)                                                                 api/v3/move_target#show
#              api_v3_characteristic_index GET  /api/v3/characteristic(.:format)                                                                  api/v3/characteristic#index
#                    api_v3_characteristic GET  /api/v3/characteristic/:id(.:format)                                                              api/v3/characteristic#show
#                        api_v3_stat_index GET  /api/v3/stat(.:format)                                                                            api/v3/stat#index
#                              api_v3_stat GET  /api/v3/stat/:id(.:format)                                                                        api/v3/stat#show
#        api_v3_super_contest_effect_index GET  /api/v3/super-contest-effect(.:format)                                                            api/v3/super_contest_effect#index
#              api_v3_super_contest_effect GET  /api/v3/super-contest-effect/:id(.:format)                                                        api/v3/super_contest_effect#show
#               api_v3_pal_park_area_index GET  /api/v3/pal-park-area(.:format)                                                                   api/v3/pal_park_area#index
#                     api_v3_pal_park_area GET  /api/v3/pal-park-area/:id(.:format)                                                               api/v3/pal_park_area#show
#             api_v3_pokeathlon_stat_index GET  /api/v3/pokeathlon-stat(.:format)                                                                 api/v3/pokeathlon_stat#index
#                   api_v3_pokeathlon_stat GET  /api/v3/pokeathlon-stat/:id(.:format)                                                             api/v3/pokeathlon_stat#show
#                     api_v3_pokedex_index GET  /api/v3/pokedex(.:format)                                                                         api/v3/pokedex#index
#                           api_v3_pokedex GET  /api/v3/pokedex/:id(.:format)                                                                     api/v3/pokedex#show
#               api_v3_pokemon_color_index GET  /api/v3/pokemon-color(.:format)                                                                   api/v3/pokemon_color#index
#                     api_v3_pokemon_color GET  /api/v3/pokemon-color/:id(.:format)                                                               api/v3/pokemon_color#show
#                api_v3_pokemon_form_index GET  /api/v3/pokemon-form(.:format)                                                                    api/v3/pokemon_form#index
#                      api_v3_pokemon_form GET  /api/v3/pokemon-form/:id(.:format)                                                                api/v3/pokemon_form#show
#             api_v3_pokemon_habitat_index GET  /api/v3/pokemon-habitat(.:format)                                                                 api/v3/pokemon_habitat#index
#                   api_v3_pokemon_habitat GET  /api/v3/pokemon-habitat/:id(.:format)                                                             api/v3/pokemon_habitat#show
#               api_v3_pokemon_shape_index GET  /api/v3/pokemon-shape(.:format)                                                                   api/v3/pokemon_shape#index
#                     api_v3_pokemon_shape GET  /api/v3/pokemon-shape/:id(.:format)                                                               api/v3/pokemon_shape#show
#             api_v3_pokemon_species_index GET  /api/v3/pokemon-species(/)(.:format)                                                              api/v3/pokemon_species#index
#                   api_v3_pokemon_species GET  /api/v3/pokemon-species/:id(/)(.:format)                                                          api/v3/pokemon_species#show
#                              api_v2_root GET  /api/v2(/)(.:format)                                                                              api/v2/root#index
#                     api_v2_ability_index GET  /api/v2/ability(/)(.:format)                                                                      api/v2/ability#index
#                           api_v2_ability GET  /api/v2/ability/:id(/)(.:format)                                                                  api/v2/ability#show
#                       api_v2_berry_index GET  /api/v2/berry(/)(.:format)                                                                        api/v2/berry#index
#                             api_v2_berry GET  /api/v2/berry/:id(/)(.:format)                                                                    api/v2/berry#show
#              api_v2_berry_firmness_index GET  /api/v2/berry-firmness(/)(.:format)                                                               api/v2/berry_firmness#index
#                    api_v2_berry_firmness GET  /api/v2/berry-firmness/:id(/)(.:format)                                                           api/v2/berry_firmness#show
#                api_v2_berry_flavor_index GET  /api/v2/berry-flavor(/)(.:format)                                                                 api/v2/berry_flavor#index
#                      api_v2_berry_flavor GET  /api/v2/berry-flavor/:id(/)(.:format)                                                             api/v2/berry_flavor#show
#              api_v2_characteristic_index GET  /api/v2/characteristic(/)(.:format)                                                               api/v2/characteristic#index
#                    api_v2_characteristic GET  /api/v2/characteristic/:id(/)(.:format)                                                           api/v2/characteristic#show
#                api_v2_contest_type_index GET  /api/v2/contest-type(/)(.:format)                                                                 api/v2/contest_type#index
#                      api_v2_contest_type GET  /api/v2/contest-type/:id(/)(.:format)                                                             api/v2/contest_type#show
#              api_v2_contest_effect_index GET  /api/v2/contest-effect(/)(.:format)                                                               api/v2/contest_effect#index
#                    api_v2_contest_effect GET  /api/v2/contest-effect/:id(/)(.:format)                                                           api/v2/contest_effect#show
#             api_v2_evolution_chain_index GET  /api/v2/evolution-chain(/)(.:format)                                                              api/v2/evolution_chain#index
#                   api_v2_evolution_chain GET  /api/v2/evolution-chain/:id(/)(.:format)                                                          api/v2/evolution_chain#show
#           api_v2_evolution_trigger_index GET  /api/v2/evolution-trigger(/)(.:format)                                                            api/v2/evolution_trigger#index
#                 api_v2_evolution_trigger GET  /api/v2/evolution-trigger/:id(/)(.:format)                                                        api/v2/evolution_trigger#show
#            api_v2_encounter_method_index GET  /api/v2/encounter-method(/)(.:format)                                                             api/v2/encounter_method#index
#                  api_v2_encounter_method GET  /api/v2/encounter-method/:id(/)(.:format)                                                         api/v2/encounter_method#show
#         api_v2_encounter_condition_index GET  /api/v2/encounter-condition(/)(.:format)                                                          api/v2/encounter_condition#index
#               api_v2_encounter_condition GET  /api/v2/encounter-condition/:id(/)(.:format)                                                      api/v2/encounter_condition#show
#                   api_v2_egg_group_index GET  /api/v2/egg-group(/)(.:format)                                                                    api/v2/egg_group#index
#                         api_v2_egg_group GET  /api/v2/egg-group/:id(/)(.:format)                                                                api/v2/egg_group#show
#   api_v2_encounter_condition_value_index GET  /api/v2/encounter-condition-value(/)(.:format)                                                    api/v2/encounter_condition_value#index
#         api_v2_encounter_condition_value GET  /api/v2/encounter-condition-value/:id(/)(.:format)                                                api/v2/encounter_condition_value#show
#                  api_v2_generation_index GET  /api/v2/generation(/)(.:format)                                                                   api/v2/generation#index
#                        api_v2_generation GET  /api/v2/generation/:id(/)(.:format)                                                               api/v2/generation#show
#                      api_v2_gender_index GET  /api/v2/gender(/)(.:format)                                                                       api/v2/gender#index
#                            api_v2_gender GET  /api/v2/gender/:id(/)(.:format)                                                                   api/v2/gender#show
#                 api_v2_growth_rate_index GET  /api/v2/growth-rate(/)(.:format)                                                                  api/v2/growth_rate#index
#                       api_v2_growth_rate GET  /api/v2/growth-rate/:id(/)(.:format)                                                              api/v2/growth_rate#show
#                        api_v2_item_index GET  /api/v2/item(/)(.:format)                                                                         api/v2/item#index
#                              api_v2_item GET  /api/v2/item/:id(/)(.:format)                                                                     api/v2/item#show
#              api_v2_item_attribute_index GET  /api/v2/item-attribute(/)(.:format)                                                               api/v2/item_attribute#index
#                    api_v2_item_attribute GET  /api/v2/item-attribute/:id(/)(.:format)                                                           api/v2/item_attribute#show
#               api_v2_item_category_index GET  /api/v2/item-category(/)(.:format)                                                                api/v2/item_category#index
#                     api_v2_item_category GET  /api/v2/item-category/:id(/)(.:format)                                                            api/v2/item_category#show
#           api_v2_item_fling_effect_index GET  /api/v2/item-fling-effect(/)(.:format)                                                            api/v2/item_fling_effect#index
#                 api_v2_item_fling_effect GET  /api/v2/item-fling-effect/:id(/)(.:format)                                                        api/v2/item_fling_effect#show
#                 api_v2_item_pocket_index GET  /api/v2/item-pocket(/)(.:format)                                                                  api/v2/item_pocket#index
#                       api_v2_item_pocket GET  /api/v2/item-pocket/:id(/)(.:format)                                                              api/v2/item_pocket#show
#                    api_v2_language_index GET  /api/v2/language(/)(.:format)                                                                     api/v2/language#index
#                          api_v2_language GET  /api/v2/language/:id(/)(.:format)                                                                 api/v2/language#show
#                    api_v2_location_index GET  /api/v2/location(/)(.:format)                                                                     api/v2/location#index
#                          api_v2_location GET  /api/v2/location/:id(/)(.:format)                                                                 api/v2/location#show
#               api_v2_location_area_index GET  /api/v2/location-area(/)(.:format)                                                                api/v2/location_area#index
#                     api_v2_location_area GET  /api/v2/location-area/:id(/)(.:format)                                                            api/v2/location_area#show
#                     api_v2_machine_index GET  /api/v2/machine(/)(.:format)                                                                      api/v2/machine#index
#                           api_v2_machine GET  /api/v2/machine/:id(/)(.:format)                                                                  api/v2/machine#show
#                        api_v2_move_index GET  /api/v2/move(/)(.:format)                                                                         api/v2/move#index
#                              api_v2_move GET  /api/v2/move/:id(/)(.:format)                                                                     api/v2/move#show
#           api_v2_move_damage_class_index GET  /api/v2/move-damage-class(/)(.:format)                                                            api/v2/move_damage_class#index
#                 api_v2_move_damage_class GET  /api/v2/move-damage-class/:id(/)(.:format)                                                        api/v2/move_damage_class#show
#                api_v2_move_ailment_index GET  /api/v2/move-ailment(/)(.:format)                                                                 api/v2/move_ailment#index
#                      api_v2_move_ailment GET  /api/v2/move-ailment/:id(/)(.:format)                                                             api/v2/move_ailment#show
#           api_v2_move_battle_style_index GET  /api/v2/move-battle-style(/)(.:format)                                                            api/v2/move_battle_style#index
#                 api_v2_move_battle_style GET  /api/v2/move-battle-style/:id(/)(.:format)                                                        api/v2/move_battle_style#show
#               api_v2_move_category_index GET  /api/v2/move-category(/)(.:format)                                                                api/v2/move_category#index
#                     api_v2_move_category GET  /api/v2/move-category/:id(/)(.:format)                                                            api/v2/move_category#show
#           api_v2_move_learn_method_index GET  /api/v2/move-learn-method(/)(.:format)                                                            api/v2/move_learn_method#index
#                 api_v2_move_learn_method GET  /api/v2/move-learn-method/:id(/)(.:format)                                                        api/v2/move_learn_method#show
#                 api_v2_move_target_index GET  /api/v2/move-target(/)(.:format)                                                                  api/v2/move_target#index
#                       api_v2_move_target GET  /api/v2/move-target/:id(/)(.:format)                                                              api/v2/move_target#show
#                      api_v2_nature_index GET  /api/v2/nature(/)(.:format)                                                                       api/v2/nature#index
#                            api_v2_nature GET  /api/v2/nature/:id(/)(.:format)                                                                   api/v2/nature#show
#                     api_v2_pokedex_index GET  /api/v2/pokedex(/)(.:format)                                                                      api/v2/pokedex#index
#                           api_v2_pokedex GET  /api/v2/pokedex/:id(/)(.:format)                                                                  api/v2/pokedex#show
#               api_v2_pokemon_color_index GET  /api/v2/pokemon-color(/)(.:format)                                                                api/v2/pokemon_color#index
#                     api_v2_pokemon_color GET  /api/v2/pokemon-color/:id(/)(.:format)                                                            api/v2/pokemon_color#show
#                api_v2_pokemon_form_index GET  /api/v2/pokemon-form(/)(.:format)                                                                 api/v2/pokemon_form#index
#                      api_v2_pokemon_form GET  /api/v2/pokemon-form/:id(/)(.:format)                                                             api/v2/pokemon_form#show
#             api_v2_pokemon_habitat_index GET  /api/v2/pokemon-habitat(/)(.:format)                                                              api/v2/pokemon_habitat#index
#                   api_v2_pokemon_habitat GET  /api/v2/pokemon-habitat/:id(/)(.:format)                                                          api/v2/pokemon_habitat#show
#               api_v2_pokemon_shape_index GET  /api/v2/pokemon-shape(/)(.:format)                                                                api/v2/pokemon_shape#index
#                     api_v2_pokemon_shape GET  /api/v2/pokemon-shape/:id(/)(.:format)                                                            api/v2/pokemon_shape#show
#             api_v2_pokemon_species_index GET  /api/v2/pokemon-species(/)(.:format)                                                              api/v2/pokemon_species#index
#                   api_v2_pokemon_species GET  /api/v2/pokemon-species/:id(/)(.:format)                                                          api/v2/pokemon_species#show
#             api_v2_pokeathlon_stat_index GET  /api/v2/pokeathlon-stat(/)(.:format)                                                              api/v2/pokeathlon_stat#index
#                   api_v2_pokeathlon_stat GET  /api/v2/pokeathlon-stat/:id(/)(.:format)                                                          api/v2/pokeathlon_stat#show
#                      api_v2_region_index GET  /api/v2/region(/)(.:format)                                                                       api/v2/region#index
#                            api_v2_region GET  /api/v2/region/:id(/)(.:format)                                                                   api/v2/region#show
#                        api_v2_stat_index GET  /api/v2/stat(/)(.:format)                                                                         api/v2/stat#index
#                              api_v2_stat GET  /api/v2/stat/:id(/)(.:format)                                                                     api/v2/stat#show
#        api_v2_super_contest_effect_index GET  /api/v2/super-contest-effect(/)(.:format)                                                         api/v2/super_contest_effect#index
#              api_v2_super_contest_effect GET  /api/v2/super-contest-effect/:id(/)(.:format)                                                     api/v2/super_contest_effect#show
#                        api_v2_type_index GET  /api/v2/type(/)(.:format)                                                                         api/v2/type#index
#                              api_v2_type GET  /api/v2/type/:id(/)(.:format)                                                                     api/v2/type#show
#                     api_v2_version_index GET  /api/v2/version(/)(.:format)                                                                      api/v2/version#index
#                           api_v2_version GET  /api/v2/version/:id(/)(.:format)                                                                  api/v2/version#show
#               api_v2_version_group_index GET  /api/v2/version-group(/)(.:format)                                                                api/v2/version_group#index
#                     api_v2_version_group GET  /api/v2/version-group/:id(/)(.:format)                                                            api/v2/version_group#show
#                     api_v2_pokemon_index GET  /api/v2/pokemon(/)(.:format)                                                                      api/v2/pokemon#index
#               api_v2_pal_park_area_index GET  /api/v2/pal-park-area(/)(.:format)                                                                api/v2/pal_park_area#index
#                     api_v2_pal_park_area GET  /api/v2/pal-park-area/:id(/)(.:format)                                                            api/v2/pal_park_area#show
#                                   api_v2 GET  /api/v2/pokemon/:id/encounters(/)(.:format)                                                       api/v2/pokemon_encounters#show
#                           api_v2_pokemon GET  /api/v2/pokemon/:id(/)(.:format)                                                                  api/v2/pokemon#show
#                      rails_pg_extras_web      /pg_extras                                                                                        RailsPgExtras::Web::Engine
#         turbo_recede_historical_location GET  /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#         turbo_resume_historical_location GET  /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#        turbo_refresh_historical_location GET  /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#            rails_postmark_inbound_emails POST /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET  /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET  /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#        new_rails_conductor_inbound_email GET  /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#            rails_conductor_inbound_email GET  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
# new_rails_conductor_inbound_email_source GET  /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
# rails_conductor_inbound_email_incinerate POST /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                       rails_service_blob GET  /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET  /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET  /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET  /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET  /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET  /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET  /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT  /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for Rswag::Ui::Engine:
# No routes defined.
#
# Routes for Rswag::Api::Engine:
# No routes defined.
#
# Routes for RailsPgExtras::Web::Engine:
#                          Prefix Verb URI Pattern                                 Controller#Action
#                         queries GET  /queries(.:format)                          rails_pg_extras/web/queries#index
#                 kill_all_action POST /actions/kill_all(.:format)                 rails_pg_extras/web/actions#kill_all
# pg_stat_statements_reset_action POST /actions/pg_stat_statements_reset(.:format) rails_pg_extras/web/actions#pg_stat_statements_reset
#           add_extensions_action POST /actions/add_extensions(.:format)           rails_pg_extras/web/actions#add_extensions
#                            root GET  /                                           rails_pg_extras/web/queries#index

Rails.application.routes.draw do
  mount OasRails::Engine => "/docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Human-friendly landing page with built-in API explorer.
  root "home#index"

  namespace :api do
    namespace :v3 do
      get "(/)", to: "root#index", as: :root

      resources :pokemon, only: %i[index show]
      resources :abilities, path: "ability", as: "ability", controller: "ability", only: %i[index show]
      resources :types, path: "type", as: "type", controller: "type", only: %i[index show]
      resources :moves, path: "move", as: "move", controller: "move", only: %i[index show]
      resources :items, path: "item", as: "item", controller: "item", only: %i[index show]
      resources :generations, path: "generation", as: "generation", controller: "generation", only: %i[index show]
      resources :version_groups, path: "version-group", as: "version_group", controller: "version_group", only: %i[index show]
      resources :regions, path: "region", as: "region", controller: "region", only: %i[index show]
      resources :versions, path: "version", as: "version", controller: "version", only: %i[index show]
      resources :evolution_chains, path: "evolution-chain", as: "evolution_chain", controller: "evolution_chain", only: %i[index show]
      resources :evolution_triggers, path: "evolution-trigger", as: "evolution_trigger", controller: "evolution_trigger", only: %i[index show]
      resources :growth_rates, path: "growth-rate", as: "growth_rate", controller: "growth_rate", only: %i[index show]
      resources :natures, path: "nature", as: "nature", controller: "nature", only: %i[index show]
      resources :genders, path: "gender", as: "gender", controller: "gender", only: %i[index show]
      resources :egg_groups, path: "egg-group", as: "egg_group", controller: "egg_group", only: %i[index show]
      resources :encounter_methods, path: "encounter-method", as: "encounter_method", controller: "encounter_method", only: %i[index show]
      resources :encounter_conditions, path: "encounter-condition", as: "encounter_condition", controller: "encounter_condition", only: %i[index show]
      resources :encounter_condition_values, path: "encounter-condition-value", as: "encounter_condition_value", controller: "encounter_condition_value", only: %i[index show]
      resources :berries, path: "berry", as: "berry", controller: "berry", only: %i[index show]
      resources :berry_firmnesses, path: "berry-firmness", as: "berry_firmness", controller: "berry_firmness", only: %i[index show]
      resources :berry_flavors, path: "berry-flavor", as: "berry_flavor", controller: "berry_flavor", only: %i[index show]
      resources :contest_types, path: "contest-type", as: "contest_type", controller: "contest_type", only: %i[index show]
      resources :contest_effects, path: "contest-effect", as: "contest_effect", controller: "contest_effect", only: %i[index show]
      resources :item_categories, path: "item-category", as: "item_category", controller: "item_category", only: %i[index show]
      resources :item_pockets, path: "item-pocket", as: "item_pocket", controller: "item_pocket", only: %i[index show]
      resources :item_attributes, path: "item-attribute", as: "item_attribute", controller: "item_attribute", only: %i[index show]
      resources :item_fling_effects, path: "item-fling-effect", as: "item_fling_effect", controller: "item_fling_effect", only: %i[index show]
      resources :languages, path: "language", as: "language", controller: "language", only: %i[index show]
      resources :locations, path: "location", as: "location", controller: "location", only: %i[index show]
      resources :location_areas, path: "location-area", as: "location_area", controller: "location_area", only: %i[index show]
      resources :machines, path: "machine", as: "machine", controller: "machine", only: %i[index show]
      resources :move_ailments, path: "move-ailment", as: "move_ailment", controller: "move_ailment", only: %i[index show]
      resources :move_battle_styles, path: "move-battle-style", as: "move_battle_style", controller: "move_battle_style", only: %i[index show]
      resources :move_categories, path: "move-category", as: "move_category", controller: "move_category", only: %i[index show]
      resources :move_damage_classes, path: "move-damage-class", as: "move_damage_class", controller: "move_damage_class", only: %i[index show]
      resources :move_learn_methods, path: "move-learn-method", as: "move_learn_method", controller: "move_learn_method", only: %i[index show]
      resources :move_targets, path: "move-target", as: "move_target", controller: "move_target", only: %i[index show]
      resources :characteristics, path: "characteristic", as: "characteristic", controller: "characteristic", only: %i[index show]
      resources :stats, path: "stat", as: "stat", controller: "stat", only: %i[index show]
      resources :super_contest_effects, path: "super-contest-effect", as: "super_contest_effect", controller: "super_contest_effect", only: %i[index show]
      resources :pal_park_areas, path: "pal-park-area", as: "pal_park_area", controller: "pal_park_area", only: %i[index show]
      resources :pokeathlon_stats, path: "pokeathlon-stat", as: "pokeathlon_stat", controller: "pokeathlon_stat", only: %i[index show]
      resources :pokedexes, path: "pokedex", as: "pokedex", controller: "pokedex", only: %i[index show]
      resources :pokemon_colors, path: "pokemon-color", as: "pokemon_color", controller: "pokemon_color", only: %i[index show]
      resources :pokemon_forms, path: "pokemon-form", as: "pokemon_form", controller: "pokemon_form", only: %i[index show]
      resources :pokemon_habitats, path: "pokemon-habitat", as: "pokemon_habitat", controller: "pokemon_habitat", only: %i[index show]
      resources :pokemon_shapes, path: "pokemon-shape", as: "pokemon_shape", controller: "pokemon_shape", only: %i[index show]
      get "pokemon-species(/)", to: "pokemon_species#index", as: :pokemon_species_index
      get "pokemon-species/:id(/)", to: "pokemon_species#show", as: :pokemon_species
    end

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
    mount RailsPgExtras::Web::Engine, at: "pg_extras"
  end
end
