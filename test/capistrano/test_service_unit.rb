# frozen_string_literal: true

require "test_helper"
require "etc"

class Capistrano::TestServiceUnit < Minitest::Test
  include CapistranoProject

  def test_description_names_application_and_stage
    assert_includes generate_unit, "Description=SolidQueue background job for app (preprod)\n"
  end

  def test_system_service_runs_as_the_capistrano_user
    unit = generate_unit(stage_config: "set :solid_queue_systemctl_user, :system")

    assert_includes unit, "User=#{Etc.getpwuid.name}\n"
  end

  def test_user_service_has_no_user_line
    refute_match(/^User=/, generate_unit)
  end

  def test_service_starts_solid_queue_with_bin_jobs
    assert_match(/^ExecStart=\S+.* exec bin\/jobs$/, generate_unit)
  end

  def test_service_has_no_reload_command
    refute_includes generate_unit, "ExecReload"
  end

  def test_service_unit_env_vars_and_files
    unit = generate_unit(stage_config: <<~RUBY)
      set :solid_queue_service_unit_env_vars, ["MALLOC_ARENA_MAX=4", "GREETING=two words"]
      set :solid_queue_service_unit_env_files, ["/var/www/app/shared/.env", "-/etc/default/app"]
    RUBY

    assert_includes unit, %(Environment="GREETING=two words"\n)
    assert_includes unit, "EnvironmentFile=/var/www/app/shared/.env\n"
    assert_includes unit, "EnvironmentFile=-/etc/default/app\n"
    assert_operator unit.index("Environment=MALLOC_ARENA_MAX=2\n"), :<, unit.index(%(Environment="MALLOC_ARENA_MAX=4"\n))
  end

  def test_service_unit_env_defaults_to_shared_settings
    unit = generate_unit(stage_config: <<~RUBY)
      set :service_unit_env_vars, ["FOO=bar"]
      set :service_unit_env_files, ["/etc/app.env"]
    RUBY

    assert_includes unit, %(Environment="FOO=bar"\n)
    assert_includes unit, "EnvironmentFile=/etc/app.env\n"
  end

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

  def test_default_env_keeps_values_starting_with_dashes
    unit = generate_unit(stage_config: 'set :default_env, { ruby_configure_opts: "--with-jemalloc=/usr/include/jemalloc --enable-yjit" }')

    assert_includes unit, "Environment='RUBY_CONFIGURE_OPTS=--with-jemalloc=/usr/include/jemalloc --enable-yjit'"
  end

  private

  def generate_unit(stage_config: "")
    run_cap("solid_queue:generate", stage_config: stage_config) do |output, status, dir|
      assert status.success?, output

      File.read(File.join(dir, "solid_queue.service"))
    end
  end
end
