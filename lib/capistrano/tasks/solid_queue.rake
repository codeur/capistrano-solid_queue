# frozen_string_literal: true

plugin = self

namespace :solid_queue do # rubocop:disable Metrics
  desc "Generate solid_queue systemd service"
  task :generate do
    on roles(fetch(:solid_queue_role)) do |role|
      service_file = File.expand_path("../../templates/solid_queue.service.erb", __FILE__)
      erb = File.read(service_file)
      File.write "solid_queue.service", ERB.new(erb, trim_mode: "-").result(binding)
    end
  end

  desc "Install solid_queue systemd service"
  task :install do
    on roles(fetch(:solid_queue_role)) do |role|
      execute :mkdir, "-p", fetch(:solid_queue_systemd_conf_dir)

      service_file = File.expand_path("../../templates/solid_queue.service.erb", __FILE__)
      erb = File.read(service_file)
      file = StringIO.new(ERB.new(erb, trim_mode: "-").result(binding))

      systemd_path = fetch(:solid_queue_systemd_conf_dir)
      path = "#{systemd_path}/#{fetch(:solid_queue_service_unit_name)}.service"

      execute :mkdir, "-p", systemd_path
      upload! file, path

      # Reload systemd
      plugin.execute_systemd("daemon-reload")
      invoke "solid_queue:enable"
    end
  end

  desc "Uninstall solid_queue systemd service"
  task :uninstall do
    invoke "solid_queue:disable"
    on roles(fetch(:solid_queue_role)) do |role|
      systemd_path = fetch(:solid_queue_systemd_conf_dir)
      execute :rm, "-f", "#{systemd_path}/#{fetch(:solid_queue_service_unit_name)}*"

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
    on roles(:app) do
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

  desc "Reload solid_queue service via systemd"
  task :reload do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("reload", fetch(:solid_queue_service_unit_name))
    end
  end

  desc "Get solid_queue service status via systemd"
  task :status do
    on roles(fetch(:solid_queue_role)) do
      plugin.execute_systemd("status", fetch(:solid_queue_service_unit_name))
    end
  end
end
