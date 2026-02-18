require "csv"
require "digest"
require "json"
require "fileutils"

module Pokeapi
  module Importers
    class BaseCsvImporter
      def initialize(source_root: default_source_root)
        @source_root = source_root
      end

      def last_run_skipped?
        @last_run_skipped == true
      end

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

          each_csv_chunk do |chunk|
            rows = build_rows(chunk)
            next if rows.empty?

            insert_rows(rows)
            imported_count += rows.size
          end

          reset_primary_key_sequence!
        end

        persist_source_checksum!(source_checksum)
        imported_count
      end

      private

      attr_reader :source_root

      def model_class
        self.class::MODEL_CLASS
      end

      def csv_path
        self.class::CSV_PATH
      end

      def batch_size
        self.class::BATCH_SIZE
      end

      def key_mapping
        self.class.const_defined?(:KEY_MAPPING) ? self.class::KEY_MAPPING : {}
      end

      def default_source_root
        ENV.fetch("POKEAPI_SOURCE_DIR", Rails.root.join("db").to_s)
      end

      def skip_unchanged_enabled?
        value = ENV.fetch("POKEAPI_SKIP_UNCHANGED", "0").to_s.strip.downcase
        %w[1 true yes on].include?(value)
      end

      def csv_file_path
        @csv_file_path ||= File.join(source_root, csv_path)
      end

      def current_source_checksum
        return nil unless File.file?(csv_file_path)

        Digest::SHA256.file(csv_file_path).hexdigest
      end

      def checksum_store_path
        ENV.fetch("POKEAPI_IMPORT_CHECKSUM_FILE", Rails.root.join("tmp/pokeapi_import_checksums.json").to_s)
      end

      def checksum_store_key
        "#{self.class.name}|#{File.expand_path(csv_file_path)}"
      end

      def skip_import_for_unchanged_source?(source_checksum)
        return false unless skip_unchanged_enabled?
        return false if source_checksum.nil?

        source_checksum == stored_source_checksum
      end

      def stored_source_checksum
        raw_entry = checksum_store.fetch(checksum_store_key, nil)
        return raw_entry["checksum"] if raw_entry.is_a?(Hash)

        raw_entry.to_s.strip.presence
      end

      def checksum_store
        @checksum_store ||= begin
          path = checksum_store_path
          if File.exist?(path)
            JSON.parse(File.read(path))
          else
            {}
          end
        rescue JSON::ParserError
          {}
        end
      end

      def persist_source_checksum!(source_checksum)
        return unless skip_unchanged_enabled?
        return if source_checksum.nil?

        checksum_store[checksum_store_key] = {
          "checksum" => source_checksum,
          "updated_at" => Time.current.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        }

        FileUtils.mkdir_p(File.dirname(checksum_store_path))
        File.write(checksum_store_path, JSON.pretty_generate(checksum_store))
      end

      def each_csv_chunk
        chunk = []

        CSV.foreach(csv_file_path, headers: true, encoding: "bom|utf-8", liberal_parsing: true) do |row|
          csv_row = normalize_csv_row(row.to_h)
          next if blank_row?(csv_row)

          chunk << csv_row
          next if chunk.size < batch_size

          yield chunk
          chunk = []
        end

        yield chunk unless chunk.empty?
      rescue CSV::MalformedCSVError => e
        raise CSV::MalformedCSVError, "#{e.message} in #{csv_file_path}"
      end

      def build_rows(chunk)
        chunk.filter_map { |csv_row| normalize_row(csv_row) }
      end

      def normalize_csv_row(csv_row)
        csv_row.each_with_object({}) do |(raw_key, value), normalized|
          next if raw_key.nil?

          key = remapped_key(raw_key)
          normalized[key] = value
        end
      end

      def remapped_key(raw_key)
        return key_mapping[raw_key] if key_mapping.key?(raw_key)

        string_key = raw_key.to_s
        return key_mapping[string_key] if key_mapping.key?(string_key)

        symbol_key = string_key.to_sym
        return key_mapping[symbol_key] if key_mapping.key?(symbol_key)

        raw_key
      end

      def blank_row?(csv_row)
        csv_row.values.all? { |value| value.to_s.strip.empty? }
      end

      def normalize_row(_csv_row)
        raise NotImplementedError
      end

      def reset_primary_key_sequence!
        model_class.connection.reset_pk_sequence!(model_class.table_name)
      end

      def clear_table!
        connection = model_class.connection
        table = connection.quote_table_name(model_class.table_name)
        connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY")
      end

      def insert_rows(rows)
        model_class.insert_all!(rows, returning: false)
      end

      def with_timestamps(attributes)
        attributes.merge(created_at: @import_timestamp, updated_at: @import_timestamp)
      end

      def required_value(row, *candidates)
        value = optional_value(row, *candidates)
        return value unless value.nil?

        raise KeyError, "missing required key. tried: #{candidates.map(&:to_s).join(', ')}"
      end

      def optional_value(row, *candidates)
        candidates.each do |candidate|
          return row[candidate] if row.key?(candidate)

          string_key = candidate.to_s
          return row[string_key] if row.key?(string_key)
        end

        nil
      end

      def to_bool(value)
        value.to_s == "1"
      end
    end
  end
end
