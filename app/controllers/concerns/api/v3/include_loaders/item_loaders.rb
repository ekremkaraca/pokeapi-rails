module Api
  module V3
    module IncludeLoaders
      module ItemLoaders
        extend ActiveSupport::Concern

        private

        # item_id => { id, name, url }
        def category_by_item_id(item_ids)
          ids = item_ids.uniq
          return {} if ids.empty?

          PokeItem.where(id: ids).includes(:category).each_with_object({}) do |item, acc|
            category = item.category
            next unless category

            acc[item.id] = {
              id: category.id,
              name: category.name,
              url: canonical_url_for_id(category.id, :api_v3_item_category_url)
            }
          end
        end

        # item_category_id => { id, name, url }
        def pocket_by_item_category_id(category_ids)
          ids = category_ids.uniq
          return {} if ids.empty?

          PokeItemCategory.where(id: ids).includes(:pocket).each_with_object({}) do |category, acc|
            pocket = category.pocket
            next unless pocket

            acc[category.id] = {
              id: pocket.id,
              name: pocket.name,
              url: canonical_url_for_id(pocket.id, :api_v3_item_pocket_url)
            }
          end
        end

        # item_pocket_id => [{ id, name, url }, ...]
        def item_categories_by_pocket_id(pocket_ids)
          ids = pocket_ids.uniq
          return {} if ids.empty?

          PokeItemPocket.where(id: ids).includes(:item_categories).each_with_object({}) do |pocket, acc|
            rows = pocket.item_categories.sort_by(&:id)
            next if rows.empty?

            acc[pocket.id] = rows.map do |category|
              {
                id: category.id,
                name: category.name,
                url: canonical_url_for_id(category.id, :api_v3_item_category_url)
              }
            end
          end
        end

        # item_attribute_id => [{ id, name, url }, ...]
        def items_by_item_attribute_id(attribute_ids)
          ids = attribute_ids.uniq
          return {} if ids.empty?

          rows = PokeItemFlagMap
            .where(item_flag_id: ids)
            .includes(:item)
            .order(:item_flag_id, :item_id)

          rows.group_by(&:item_flag_id).transform_values do |item_rows|
            item_rows.filter_map do |row|
              item = row.item
              next unless item

              {
                id: item.id,
                name: item.name,
                url: canonical_url_for_id(item.id, :api_v3_item_url)
              }
            end
          end
        end

        # item_fling_effect_id => [{ id, name, url }, ...]
        def items_by_fling_effect_id(effect_ids)
          ids = effect_ids.uniq
          return {} if ids.empty?

          PokeItemFlingEffect.where(id: ids).includes(:items).each_with_object({}) do |effect, acc|
            rows = effect.items.sort_by(&:id)
            next if rows.empty?

            acc[effect.id] = rows.map do |item|
              {
                id: item.id,
                name: item.name,
                url: canonical_url_for_id(item.id, :api_v3_item_url)
              }
            end
          end
        end

        # machine_id => { id, name, url }
        def item_by_machine_id(machine_ids)
          ids = machine_ids.uniq
          return {} if ids.empty?

          PokeMachine.where(id: ids).includes(:item).each_with_object({}) do |machine, acc|
            item = machine.item
            next unless item

            acc[machine.id] = {
              id: item.id,
              name: item.name,
              url: canonical_url_for_id(item.id, :api_v3_item_url)
            }
          end
        end
      end
    end
  end
end
