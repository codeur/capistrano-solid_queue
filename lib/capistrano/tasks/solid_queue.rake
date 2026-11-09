# frozen_string_literal: true

plugin = self

namespace :solid_queue do # rubocop:disable Metrics
  desc "Generate solid_queue systemd service"
  task :generate do
    on roles(fetch(:solid_queue_role)) do
      File.write "solid_queue.service", plugin.service_unit(binding)
    end
  end

  desc "Install solid_queue systemd service"
  task :install do
    on roles(fetch(:solid_queue_role)) do
      tmp_path = File.join(fetch(:tmp_dir), plugin.service_unit_file)
      upload! StringIO.new(plugin.service_unit(binding)), tmp_path
      plugin.sudo_if_needed("mkdir", "-p", fetch(:solid_queue_systemd_conf_dir))
      plugin.sudo_if_needed("mv", tmp_path, File.join(fetch(:solid_queue_systemd_conf_dir), plugin.service_unit_file))

      plugin.execute_systemd("daemon-reload")
      plugin.execute_systemd("enable", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Uninstall solid_queue systemd service"
  task :uninstall do
    invoke "solid_queue:disable"
    on roles(fetch(:solid_queue_role)) do
      plugin.sudo_if_needed("rm", "-f", File.join(fetch(:solid_queue_systemd_conf_dir), plugin.service_unit_file))
      plugin.execute_systemd("daemon-reload")
    end
  end

  desc "Enable solid_queue systemd service"
  task :enable do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("enable", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Disable solid_queue systemd service"
  task :disable do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("disable", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Quiet solid_queue (start graceful termination)"
  task :quiet do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("kill", "-s", "SIGTERM", fetch(:solid_queue_service_unit_name), raise_on_non_zero_exit: false)
    end
  end

  desc "Start solid_queue service via systemd"
  task :start do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("start", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Stop solid_queue service via systemd"
  task :stop do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("stop", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Restart solid_queue service via systemd"
  task :restart do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("restart", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Get solid_queue service status via systemd"
  task :status do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("status", fetch(:solid_queue_service_unit_name), raise_on_non_zero_exit: false)
    end
  end
end
