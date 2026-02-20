module Api
  module V3
    # Handles sparse fieldsets for v3 resources via `fields=`.
    module FieldSelectable
      private

      # Parses and validates requested field names against an allowlist.
      # Returns default fields when param is omitted/blank.
      def fieldset_for(allowed:, default:)
        raw_fields = params[:fields].to_s.strip
        return default if raw_fields.empty?

        allowed_names = allowed.map(&:to_s)
        requested_names = raw_fields.split(",").map(&:strip).reject(&:empty?).uniq
        invalid_names = requested_names - allowed_names

        if invalid_names.any?
          raise BaseController::InvalidQueryParameterError.new(
            param: "fields",
            invalid_values: invalid_names,
            allowed_values: allowed_names
          )
        end

        requested_names.map(&:to_sym)
      end

      # Keeps response payload keys limited to the selected field set.
      def project_payload(payload, fields:)
        payload.slice(*fields)
      end

      # Ensures include-backed keys are present when an include is requested.
      def merge_fields_and_includes(fields, includes:)
        fields | includes
      end
    end
  end
end
