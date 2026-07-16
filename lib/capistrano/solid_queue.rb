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
        set_if_empty :solid_queue_systemctl_user, :user
        set_if_empty :solid_queue_systemd_conf_dir, -> { fetch_systemd_unit_path }

        # Command executed by the systemd unit (concatenated after `bundle exec`).
        # Override with e.g. "bin/jobs" for SolidQueue >= 0.4 setups.
        set_if_empty :solid_queue_command, "rake solid_queue:start"

        # Unix user the service runs as when using `:system` mode. Falls back to
        # `:run_as` (shared with other systemd capistrano plugins) and finally
        # the SSH `:user` capistrano connects with.
        set_if_empty :solid_queue_user, -> { fetch(:run_as, fetch(:user)) }

        # SolidQueue could have a stripped down or more complex version of the environment variables
        set_if_empty :solid_queue_service_unit_env_files, -> { fetch(:service_unit_env_files, []) }
        set_if_empty :solid_queue_service_unit_env_vars, -> { fetch(:service_unit_env_vars, []) }
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
        sudo_if_needed(*systemd_command(*args), raise_on_non_zero_exit: true)
      end

      def sudo_if_needed(*command, raise_on_non_zero_exit: true)
        if fetch(:solid_queue_systemctl_user) == :system
          backend.sudo command.join(" ")
        else
          backend.execute(*command, raise_on_non_zero_exit: raise_on_non_zero_exit)
        end
      end

      def systemd_command(*args)
        command = ["/bin/systemctl"]

        unless fetch(:solid_queue_systemctl_user) == :system
          command << "--user"
        end

        command + args
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
