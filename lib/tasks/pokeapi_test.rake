namespace :test do
  desc "Prepare test database (creates test db and loads schema)"
  task :db => :environment do
    puts "Preparing test database..."
    ActiveRecord::Base.establish_connection(:test)
    ActiveRecord::Schema.verbose = false

    # Create test database if it doesn't exist
    ActiveRecord::Base.connection.create_database(ActiveRecord::Base.connection.current_database)

    # Load schema
    ActiveRecord::Tasks::DatabaseTasks.load_current(
      ActiveRecord::Base.connection_config[:active_record_env],
      File.expand_path("../../db/schema.rb", __dir__)
      )
    puts "Test database prepared."
  end

  desc "Run integration tests (all /api/v2/* and /api/v3/* endpoints)"
  task :integration => :environment do
    puts "Running integration tests..."
    system("RAILS_ENV=test bin/rails test test/integration/**/*_test.rb --format=documentation", exception: true)
  end

  desc "Run smoke tests (fast subset of integration tests for quick CI feedback)"
  task :integration_smoke => :environment do
    puts "Running smoke tests..."

    # Run a focused subset of key integration tests for fast feedback
    smoke_tests = [
      "test/integration/api/v2/pokemon_controller_test.rb",
      "test/integration/api/v3/pokemon_controller_test.rb",
      "test/integration/api/v3/ability_controller_test.rb",
      "test/integration/home_controller_test.rb",
      "test/integration/api/v2/pokemon_encounters_controller_test.rb"
    ]

    smoke_tests.each do |test_path|
      puts "  Running: #{test_path}"
      system("RAILS_ENV=test bin/rails test #{test_path} --format=documentation", exception: true)
    end

    puts "Smoke tests completed."
  end

  desc "Run model tests"
  task :models => :environment do
    puts "Running model tests..."
    system("RAILS_ENV=test bin/rails test test/models/**/*_test.rb --format=documentation", exception: true)
  end

  desc "Run service/importer tests"
  task :services => :environment do
    puts "Running service tests..."
    system("RAILS_ENV=test bin/rails test test/services/**/*_test.rb --format=documentation", exception: true)
  end

  desc "Run lib tests (gem runtime smoke, parity tools, etc.)"
  task :lib => :environment do
    puts "Running lib tests..."
    system("RAILS_ENV=test bin/rails test test/lib/**/*_test.rb --format=documentation", exception: true)
  end

  desc "Run all tests"
  task :all => :environment do
    puts "Running all tests..."
    system("RAILS_ENV=test bin/rails test --format=documentation", exception: true)
  end
end
