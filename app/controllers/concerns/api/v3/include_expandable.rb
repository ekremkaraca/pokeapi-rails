module Api
  module V3
    # Parses include expansions from `include=` with strict allowlists.
    module IncludeExpandable
      private

      # Returns included relationship names as symbols.
      # Raises InvalidQueryParameterError for unsupported includes.
      def include_set_for(allowed:)
        raw_include = params[:include].to_s.strip
        return [] if raw_include.empty?

        allowed_names = allowed.map(&:to_s)
        requested_names = raw_include.split(",").map(&:strip).reject(&:empty?).uniq
        invalid_names = requested_names - allowed_names

        if invalid_names.any?
          raise BaseController::InvalidQueryParameterError.new(
            param: "include",
            invalid_values: invalid_names,
            allowed_values: allowed_names
          )
        end

        requested_names.map(&:to_sym)
      end
    end
  end
end
