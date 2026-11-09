# frozen_string_literal: true

require "test_helper"

class Capistrano::TestTasks < Minitest::Test
  include CapistranoProject

  USER_MODE = <<~RUBY
    set :tmp_dir, "."
    set :solid_queue_systemd_conf_dir, "units"
    SSHKit.config.command_map[:"/bin/systemctl"] = "true"
  RUBY

  SYSTEM_MODE = <<~RUBY
    set :solid_queue_systemctl_user, :system
    set :tmp_dir, "."
    set :solid_queue_systemd_conf_dir, "units"
    SSHKit.config.command_map[:sudo] = "echo"
  RUBY

  def test_install_moves_the_unit_into_place_and_enables_it_on_the_same_host
    stage_config = USER_MODE + <<~RUBY
      task(:enable_task_invoked) { puts "enable task invoked" }
      before "solid_queue:enable", :enable_task_invoked
    RUBY

    run_cap("solid_queue:install", stage_config: stage_config) do |output, status, dir|
      assert status.success?, output
      assert File.exist?(File.join(dir, "units", "app_solid_queue_preprod.service")), output
      refute_includes output, "enable task invoked"
      assert_includes output, "true --user enable app_solid_queue_preprod"
      assert_operator output.index("true --user daemon-reload"), :<, output.index("true --user enable app_solid_queue_preprod")
    end
  end

  def test_system_install_moves_the_unit_with_sudo
    run_cap("solid_queue:install", stage_config: SYSTEM_MODE) do |output, status|
      assert status.success?, output
      assert_includes output, "echo mv ./app_solid_queue_preprod.service units/app_solid_queue_preprod.service"
    end
  end

  def test_uninstall_removes_only_this_service
    stage_config = USER_MODE + <<~RUBY
      FileUtils.mkdir_p("units")
      FileUtils.touch(["units/app_solid_queue_preprod.service", "units/app_solid_queue_preprod_eu.service"])
    RUBY

    run_cap("solid_queue:uninstall", stage_config: stage_config) do |output, status, dir|
      assert status.success?, output
      refute File.exist?(File.join(dir, "units", "app_solid_queue_preprod.service")), output
      assert File.exist?(File.join(dir, "units", "app_solid_queue_preprod_eu.service")), output
    end
  end

  def test_system_uninstall_removes_the_unit_with_sudo
    run_cap("solid_queue:uninstall", stage_config: SYSTEM_MODE) do |output, status|
      assert status.success?, output
      assert_includes output, "echo rm -f units/app_solid_queue_preprod.service"
    end
  end

  def test_deploy_stops_then_starts_the_service
    stage_config = <<~RUBY
      set :sshkit_backend, SSHKit::Backend::Printer
      set :repo_url, "https://example.invalid/app.git"
    RUBY

    run_cap("deploy", stage_config: stage_config) do |output, status|
      assert status.success?, output
      assert_equal %w[solid_queue:stop solid_queue:start], output.scan(/^\d\d:\d\d (solid_queue:\w+)$/).flatten
    end
  end

  def test_there_is_no_reload_task
    run_cap("--tasks") do |output, status|
      assert status.success?, output
      assert_includes output, "solid_queue:restart"
      refute_includes output, "solid_queue:reload"
    end
  end
end
