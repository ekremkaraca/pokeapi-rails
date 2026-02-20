module Api
  module V3
    # Shared orchestration for v3 list/detail actions:
    # include parsing -> fieldset -> filter/sort -> stale check -> render.
    module EndpointFlow
      private

      # Generic list flow used by resource controllers.
      # Controllers provide resource-specific hooks:
      # - summary_fields / summary_includes
      # - summary_include_map
      # - summary_payload
      def render_index_flow(scope:, cache_key:, sort_allowed:, sort_default:, q_column: :name, filter_allowed: %i[name])
        includes = include_set_for(allowed: summary_includes)
        fields = merge_fields_and_includes(
          fieldset_for(allowed: summary_fields, default: summary_fields),
          includes: includes
        )

        scope = apply_q_filter(scope, column: q_column)
        scope = apply_filter_params(scope, allowed: filter_allowed)
        scope, sort_key = apply_sort(scope, allowed: sort_allowed, default: sort_default)

        return unless stale_collection?(
          scope: scope,
          cache_key: cache_key,
          variation: list_variation.merge(
            fields: fields.join(","),
            include: includes.join(","),
            sort: sort_key,
            filter: filter_variation(allowed: filter_allowed)
          )
        )

        records, metadata = paginate(scope)
        include_map = summary_include_map(records: records, includes: includes)

        render json: metadata.merge(
          results: records.map do |record|
            project_payload(summary_payload(record, includes: includes, include_map: include_map), fields: fields)
          end
        )
      end

      # Generic detail flow used by resource controllers.
      # Controllers provide detail_* hooks mirroring list behavior.
      def render_show_flow(record:, cache_key:)
        includes = include_set_for(allowed: detail_includes)
        fields = merge_fields_and_includes(
          fieldset_for(allowed: detail_fields, default: detail_fields),
          includes: includes
        )

        return unless stale_resource?(
          record: record,
          cache_key: cache_key,
          variation: { fields: fields.join(","), include: includes.join(",") }
        )

        include_map = detail_include_map(record: record, includes: includes)
        render json: project_payload(detail_payload(record, includes: includes, include_map: include_map), fields: fields)
      end

      # Shared cache variation keys for collection actions.
      def list_variation
        {
          q: params[:q].to_s.strip,
          limit: normalized_limit,
          offset: normalized_offset
        }
      end

      # Extension point for list include preloading.
      # Expected return: hash keyed by resource id.
      def summary_include_map(records:, includes:)
        {}
      end

      # Extension point for detail include preloading.
      # Expected return: hash keyed by resource id.
      def detail_include_map(record:, includes:)
        {}
      end

      # Shared include map builder for collection payloads.
      # include_key: symbol expected in include list (e.g. :pokemon)
      # loader: private loader method name that accepts array of ids
      def include_map_for_collection(records:, includes:, include_key:, loader:)
        return {} unless includes.include?(include_key)

        send(loader, records.map(&:id))
      end

      # Shared include map builder for detail payloads.
      # include_key: symbol expected in include list (e.g. :pokemon)
      # loader: private loader method name that accepts array of ids
      def include_map_for_resource(record:, includes:, include_key:, loader:)
        return {} unless includes.include?(include_key)

        send(loader, [record.id])
      end
    end
  end
end
