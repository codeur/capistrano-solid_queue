# frozen_string_literal: true

require "capistrano/plugin"

module Capistrano
  module SolidQueue
    class Systemd < Capistrano::Plugin
      def set_defaults
        set_if_empty :solid_queue_role, "db"
        set_if_empty :solid_queue_access_log, -> { File.join(shared_path, "log", "solid_queue.log") }
        set_if_empty :solid_queue_error_log, -> { File.join(shared_path, "log", "solid_queue.log") }
        set_if_empty :solid_queue_service_unit_name, -> { "#{fetch(:application)}_solid_queue_#{fetch(:stage)}" }
        set_if_empty :solid_queue_systemd_conf_dir, -> { fetch_systemd_unit_path }
      end

      def define_tasks
        eval_rakefile File.expand_path("../tasks/solid_queue.rake", __FILE__)
      end

      def register_hooks
        after "deploy:starting", "solid_queue:quiet"
        after "deploy:updated", "solid_queue:stop"
        after "deploy:published", "solid_queue:start"
        after "deploy:failed", "solid_queue:restart"
      end

      def execute_systemd(*args, raise_on_non_zero_exit: true)
        command = ["/bin/systemctl", "--user"] + args
        backend.execute(*command, raise_on_non_zero_exit: raise_on_non_zero_exit)
      end

      def fetch_systemd_unit_path
        if fetch(:solid_queue_systemctl_user) == :system
          "/etc/systemd/system/"
        else
          home_dir = backend.capture :pwd
          File.join(home_dir, ".config", "systemd", "user")
        end
      end
    end
  end
end

require_relative "solid_queue/version"
