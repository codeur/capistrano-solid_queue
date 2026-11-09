# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
