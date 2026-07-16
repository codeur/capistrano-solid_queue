## [Unreleased]

- Make systemd unit environment variables configurable via
  `:solid_queue_service_unit_env_files` and `:solid_queue_service_unit_env_vars`
  (inspired by `capistrano-sidekiq`). Both fall back to shared
  `:service_unit_env_files` / `:service_unit_env_vars` when set.
- Make the executed command configurable via `:solid_queue_command`
  (default: `"rake solid_queue:start"`) so SolidQueue >= 0.4 setups can use
  `"bin/jobs"`.
- Fix: `[Install] WantedBy=` now switches to `multi-user.target` when running
  in `:system` mode (previously always `default.target`, which prevented boot
  activation of system units).
- Fix: in `:system` mode the service now runs as `:solid_queue_user`
  (defaults to `:run_as` → `:user`) instead of implicitly running as root.
- **Breaking**: Capistrano's `default_env` is no longer rendered into the
  systemd unit file. `MALLOC_ARENA_MAX=2` is no longer hardcoded either. Pass
  what you need explicitly via the new configuration hooks. `RAILS_ENV` is
  still set from the current stage.

## [0.1.2] - 2025-06-12

- Quiet task only runs on :solid_queue_role [#3](https://github.com/codeur/capistrano-solid_queue/pull/5) by [@bashcoder](https://github.com/bashcoder)

## [0.1.1] - 2025-03-27

- Fix system user [#2](https://github.com/codeur/capistrano-solid_queue/pull/2) by [@lubosch](https://github.com/lubosch)

## [0.1.0] - 2024-04-22

- Initial release
