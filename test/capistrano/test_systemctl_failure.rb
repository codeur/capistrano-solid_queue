# frozen_string_literal: true

require "test_helper"

class Capistrano::TestSystemctlFailure < Minitest::Test
  include CapistranoProject

  def test_quiet_goes_on_when_systemctl_fails
    run_cap("solid_queue:quiet", stage_config: 'SSHKit.config.command_map[:"/bin/systemctl"] = "false"') do |output, status|
      assert_includes output, "false --user kill -s SIGTERM app_solid_queue_preprod"
      assert status.success?, output
    end
  end

  def test_quiet_goes_on_when_systemctl_fails_as_system_user
    stage_config = <<~RUBY
      set :solid_queue_systemctl_user, :system
      SSHKit.config.command_map[:sudo] = "false"
    RUBY

    run_cap("solid_queue:quiet", stage_config: stage_config) do |output, status|
      assert_includes output, "false /bin/systemctl kill -s SIGTERM app_solid_queue_preprod"
      assert status.success?, output
    end
  end

  def test_status_goes_on_when_the_service_is_not_running
    run_cap("solid_queue:status", stage_config: 'SSHKit.config.command_map[:"/bin/systemctl"] = "false"') do |output, status|
      assert_includes output, "false --user status app_solid_queue_preprod"
      assert status.success?, output
    end
  end

  def test_stop_aborts_when_systemctl_fails
    run_cap("solid_queue:stop", stage_config: 'SSHKit.config.command_map[:"/bin/systemctl"] = "false"') do |output, status|
      assert_includes output, "false --user stop app_solid_queue_preprod"
      assert_includes output, "SSHKit::Command::Failed: /bin/systemctl exit status"
      refute status.success?, output
    end
  end
end
