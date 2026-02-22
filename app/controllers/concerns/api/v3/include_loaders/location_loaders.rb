module Api
  module V3
    module IncludeLoaders
      module LocationLoaders
        extend ActiveSupport::Concern

        private

        # location_id => { id, name, url }
        def region_by_location_id(location_ids)
          ids = location_ids.uniq
          return {} if ids.empty?

          PokeLocation.where(id: ids).includes(:region).each_with_object({}) do |location, acc|
            region = location.region
            next unless region

            acc[location.id] = {
              id: region.id,
              name: region.name,
              url: canonical_url_for_id(region.id, :api_v3_region_url)
            }
          end
        end

        # location_area_id => { id, name, url }
        def location_by_location_area_id(area_ids)
          ids = area_ids.uniq
          return {} if ids.empty?

          PokeLocationArea.where(id: ids).includes(:location).each_with_object({}) do |area, acc|
            location = area.location
            next unless location

            acc[area.id] = {
              id: location.id,
              name: location.name,
              url: canonical_url_for_id(location.id, :api_v3_location_url)
            }
          end
        end
      end
    end
  end
end
