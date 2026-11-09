# frozen_string_literal: true

require "test_helper"

class Capistrano::TestServiceUnit < Minitest::Test
  include CapistranoProject

  def test_rails_env_is_capistrano_rails_env
    unit = generate_unit(stage_config: 'set :rails_env, "production"')

    assert_includes unit, "Environment='RAILS_ENV=production'"
  end

  def test_rails_env_defaults_to_stage
    unit = generate_unit

    assert_includes unit, "Environment='RAILS_ENV=preprod'"
  end

  private

  def generate_unit(stage_config: "")
    run_cap("solid_queue:generate", stage_config: stage_config) do |output, status, dir|
      assert status.success?, output

      File.read(File.join(dir, "solid_queue.service"))
    end
  end
end
