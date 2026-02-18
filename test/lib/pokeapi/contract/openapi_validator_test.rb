require "test_helper"
require "tempfile"
require Rails.root.join("lib/pokeapi/contract/openapi_validator")

class Pokeapi::Contract::OpenapiValidatorTest < ActiveSupport::TestCase
  test "accepts valid minimal v3 openapi file" do
    file = write_yaml(
      <<~YAML
        openapi: 3.0.3
        info:
          title: Demo
          version: 0.1.0
        paths:
          /api/v3/pokemon:
            get:
              responses:
                "200":
                  description: ok
      YAML
    )

    validator = Pokeapi::Contract::OpenapiValidator.new(path: file.path)
    assert_equal true, validator.validate
  end

  test "rejects non v3 path entries" do
    file = write_yaml(
      <<~YAML
        openapi: 3.0.3
        info:
          title: Demo
          version: 0.1.0
        paths:
          /api/v2/pokemon:
            get:
              responses:
                "200":
                  description: ok
      YAML
    )

    error = assert_raises(ArgumentError) do
      Pokeapi::Contract::OpenapiValidator.new(path: file.path).validate
    end

    assert_match(%r{only /api/v3 paths are allowed}, error.message)
  end

  test "rejects operation without responses" do
    file = write_yaml(
      <<~YAML
        openapi: 3.0.3
        info:
          title: Demo
          version: 0.1.0
        paths:
          /api/v3/pokemon:
            get:
              summary: no responses
      YAML
    )

    error = assert_raises(ArgumentError) do
      Pokeapi::Contract::OpenapiValidator.new(path: file.path).validate
    end

    assert_match(/missing responses/, error.message)
  end

  private

  def write_yaml(contents)
    file = Tempfile.new("openapi-v3")
    file.write(contents)
    file.flush
    file
  end
end
