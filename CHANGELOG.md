# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `:solid_queue_service_unit_env_vars` and `:solid_queue_service_unit_env_files` add `Environment=` and `EnvironmentFile=` lines to the systemd service. They default to `:service_unit_env_vars` and `:service_unit_env_files`, as in capistrano3-puma and capistrano-sidekiq ([#13](https://github.com/codeur/capistrano-solid_queue/pull/13), from [#6](https://github.com/codeur/capistrano-solid_queue/pull/6) by [@floriancrusius](https://github.com/floriancrusius)).
- A Configuration section in the README ([#13](https://github.com/codeur/capistrano-solid_queue/pull/13)).

### Changed

- In `:system` mode, the service runs as the user Capistrano connects with instead of root. Run `cap <stage> solid_queue:install` again, then give that user back the files the service may have created as root ([#13](https://github.com/codeur/capistrano-solid_queue/pull/13), from [#6](https://github.com/codeur/capistrano-solid_queue/pull/6) by [@floriancrusius](https://github.com/floriancrusius)).
- The service description names the application and the stage ([#13](https://github.com/codeur/capistrano-solid_queue/pull/13)).
- Deploys no longer run `solid_queue:quiet` after `deploy:starting`. Solid Queue has no quiet mode: the `SIGTERM` it sends starts a shutdown, so jobs stopped for the whole deploy. The service is now stopped after `deploy:updated` and started after `deploy:published` ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- Ruby 3.1 or later is required ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- Capistrano 3.5 or later is required: `Capistrano::Plugin` doesn't exist before ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- The service starts Solid Queue with `bin/jobs`, as Solid Queue documents, instead of `rake solid_queue:start`. The application needs `bin/jobs`: Rails 8 applications have it, and `bin/rails solid_queue:install` creates it. Run `cap <stage> solid_queue:install` again to update an installed service ([#16](https://github.com/codeur/capistrano-solid_queue/pull/16)).

### Removed

- `solid_queue:reload` and the `ExecReload=` line of the service: the `SIGTSTP` it sent didn't reload Solid Queue ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- `solid_queue:quiet`: Solid Queue has no quiet mode, the `SIGTERM` it sent started a shutdown. `solid_queue:stop` stops Solid Queue gracefully ([#16](https://github.com/codeur/capistrano-solid_queue/pull/16)).

### Fixed

- In `:system` mode, `solid_queue:install` and `solid_queue:uninstall` work when Capistrano doesn't connect as root: the unit is uploaded to `:tmp_dir`, then moved and removed with `sudo` ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- `solid_queue:install` enables the service on each server right after uploading its unit there, instead of running `solid_queue:enable` on every server from the first one ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- `solid_queue:uninstall` removes only the unit of the service, not every file whose name starts with it ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- `solid_queue:status` shows the status of a stopped service instead of failing ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- The README lists the hooks the plugin registers ([#14](https://github.com/codeur/capistrano-solid_queue/pull/14)), tells to enable lingering for user services, and links to the right code of conduct ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).
- The README says when the gem isn't needed (Solid Queue running inside Puma) and how to pass `bin/jobs` options ([#16](https://github.com/codeur/capistrano-solid_queue/pull/16)).
- The gem's changelog link points to this file, and the gem no longer ships its outdated RBS signature, `.standard.yml` and `Rakefile` ([#15](https://github.com/codeur/capistrano-solid_queue/pull/15)).

## [0.1.3] - 2026-11-09

### Fixed

- `RAILS_ENV` of the systemd service comes from `:rails_env`, falling back to `:stage` ([#9](https://github.com/codeur/capistrano-solid_queue/pull/9)). Run `cap <stage> solid_queue:install` again to update an installed service.
- `default_env` values in the systemd service are expanded by the server shell, as in Capistrano commands, so `RBENV_ROOT=$HOME/.rbenv` set by capistrano-rbenv becomes an absolute path ([#12](https://github.com/codeur/capistrano-solid_queue/pull/12)). Run `cap <stage> solid_queue:install` again to update an installed service.
- `solid_queue:quiet` no longer aborts the deploy when `systemctl` fails, as before 0.1.1 ([#10](https://github.com/codeur/capistrano-solid_queue/pull/10)).
- The README example with `load_hooks: false` installs `Capistrano::SolidQueue::Systemd` ([#11](https://github.com/codeur/capistrano-solid_queue/pull/11)).

## [0.1.2] - 2025-06-12

### Fixed

- Quiet task only runs on `:solid_queue_role` ([#5](https://github.com/codeur/capistrano-solid_queue/pull/5)) by [@bashcoder](https://github.com/bashcoder).

## [0.1.1] - 2025-03-27

### Fixed

- System user mode, with `set :solid_queue_systemctl_user, :system` ([#2](https://github.com/codeur/capistrano-solid_queue/pull/2)) by [@lubosch](https://github.com/lubosch).

## [0.1.0] - 2024-04-22

### Added

- Initial release.

[unreleased]: https://github.com/codeur/capistrano-solid_queue/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/codeur/capistrano-solid_queue/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/codeur/capistrano-solid_queue/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/codeur/capistrano-solid_queue/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/codeur/capistrano-solid_queue/releases/tag/v0.1.0
