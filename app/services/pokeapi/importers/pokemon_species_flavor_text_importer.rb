require "csv"

module Pokeapi
  module Importers
    class PokemonSpeciesFlavorTextImporter < BaseCsvImporter
      class MalformedCsvRowError < StandardError; end

      MODEL_CLASS = PokePokemonSpeciesFlavorText
      CSV_PATH = "data/v2/csv/pokemon_species_flavor_text.csv"
      BATCH_SIZE = 5_000

      def run!
        imported_count = 0
        @import_timestamp = Time.current
        @last_run_skipped = false
        source_checksum = current_source_checksum

        if skip_import_for_unchanged_source?(source_checksum)
          @last_run_skipped = true
          return 0
        end

        model_class.transaction do
          clear_table!

          rows = []

          CSV.foreach(csv_file_path, headers: true, encoding: "bom|utf-8", liberal_parsing: true) do |row|
            csv_row = row.to_h
            next if blank_row?(csv_row)

            rows << normalize_row(csv_row)
            next if rows.size < batch_size

            insert_rows(rows)
            imported_count += rows.size
            rows.clear
          end

          unless rows.empty?
            insert_rows(rows)
            imported_count += rows.size
          end

          reset_primary_key_sequence!
        end

        persist_source_checksum!(source_checksum)
        imported_count
      rescue CSV::MalformedCSVError => e
        raise MalformedCsvRowError, "#{e.message} in #{csv_file_path}"
      end

      private

      def normalize_row(csv_row)
        with_timestamps(
          species_id: required_value(csv_row, :species_id).to_i,
          version_id: required_value(csv_row, :version_id).to_i,
          language_id: required_value(csv_row, :language_id).to_i,
          flavor_text: optional_value(csv_row, :flavor_text)
        )
      end

      def blank_row?(csv_row)
        csv_row.values.all? { |value| value.to_s.strip.empty? }
      end
    end
  end
end
