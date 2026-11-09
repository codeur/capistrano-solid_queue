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

  def test_default_env_is_expanded_by_the_server_shell
    unit = generate_unit(stage_config: 'set :default_env, { rbenv_root: "$HOME/.rbenv", rbenv_version: "3.3.0" }')

    assert_includes unit, "Environment='RBENV_ROOT=#{Dir.home}/.rbenv'"
    assert_includes unit, "Environment='RBENV_VERSION=3.3.0'"
  end

  def test_default_env_keeps_double_quotes
    unit = generate_unit(stage_config: %(set :default_env, { greeting: 'say "hi"' }))

    assert_includes unit, %(Environment='GREETING=say "hi"')
  end

  private

  def generate_unit(stage_config: "")
    run_cap("solid_queue:generate", stage_config: stage_config) do |output, status, dir|
      assert status.success?, output

      File.read(File.join(dir, "solid_queue.service"))
    end
  end
end
