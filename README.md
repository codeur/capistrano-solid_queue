# Capistrano Systemd integration for SolidQueue

Runs [Solid Queue](https://github.com/rails/solid_queue) in its own process, with `bin/jobs`, as a systemd service. The application needs `bin/jobs`: Rails 8 applications have it, and `bin/rails solid_queue:install` creates it. If Solid Queue runs inside Puma with its plugin (`plugin :solid_queue`), you don't need this gem: both would start a Solid Queue supervisor.

Adds the following capistrano commands:

```sh
cap solid_queue:disable               # Disable solid_queue systemd service
cap solid_queue:enable                # Enable solid_queue systemd service
cap solid_queue:generate              # Generate solid_queue systemd service
cap solid_queue:install               # Install solid_queue systemd service
cap solid_queue:restart               # Restart solid_queue service via systemd
cap solid_queue:start                 # Start solid_queue service via systemd
cap solid_queue:status                # Get solid_queue service status via systemd
cap solid_queue:stop                  # Stop solid_queue service via systemd
cap solid_queue:uninstall             # Uninstall solid_queue systemd service
```


## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'capistrano-solid_queue', require: false
end
```

And then execute:

    $ bundle

```ruby
# Capfile

require 'capistrano/solid_queue'
install_plugin Capistrano::SolidQueue::Systemd
```

To prevent loading [the hooks](lib/capistrano/solid_queue.rb) of the plugin, add false to the load_hooks param.
```ruby
# Capfile

install_plugin Capistrano::SolidQueue::Systemd, load_hooks: false
```

Then run once

```sh
bundle exec cap production solid_queue:install
```

for the initial setup. This will copy a [`systemd` service definition](lib/capistrano/templates/solid_queue.service.erb) to `~/.config/systemd/user/<application>_solid_queue_<stage>.service` on your server marked with Capistrano role `db`.

It will also `enable` it in `systemd`, so that you can then run commands such as:

```sh
systemctl --user status your_app_solid_queue_production
systemctl --user start your_app_solid_queue_production
systemctl --user stop your_app_solid_queue_production
systemctl --user restart your_app_solid_queue_production
```

through their Capistrano counterparts, ex: `bundle exec cap production solid_queue:restart`.

A user service only runs while its user has a session open on the server, unless lingering is enabled for that user. Enable it once on each server, with the user Capistrano connects with:

```sh
sudo loginctl enable-linger deploy
```

## Usage

The plugin registers these Capistrano hooks:

- after `deploy:updated`, `solid_queue:stop` stops the service;
- after `deploy:published`, `solid_queue:start` starts the service on the new release;
- after `deploy:failed`, `solid_queue:restart` restarts the service.

See [`#register_hooks`](lib/capistrano/solid_queue.rb)

## Configuration

These variables can be set in `config/deploy.rb` or in a stage file. The values below are the defaults.

```ruby
set :solid_queue_role, "db"
set :solid_queue_access_log, -> { File.join(shared_path, "log", "solid_queue.log") }
set :solid_queue_error_log, -> { File.join(shared_path, "log", "solid_queue.log") }
set :solid_queue_service_unit_name, -> { "#{fetch(:application)}_solid_queue_#{fetch(:stage)}" }
set :solid_queue_service_unit_env_vars, -> { fetch(:service_unit_env_vars, []) }
set :solid_queue_service_unit_env_files, -> { fetch(:service_unit_env_files, []) }
```

After changing any of them, run `cap <stage> solid_queue:install` again: deploys don't regenerate the service.

### User or system service

By default, Solid Queue runs as a user service: `systemctl --user`, with the unit file in `~/.config/systemd/user`. To run it as a system service instead:

```ruby
set :solid_queue_systemctl_user, :system
```

The unit file then goes to `/etc/systemd/system/`, `systemctl` runs through `sudo`, and the service runs as the user Capistrano connects with. `:solid_queue_systemd_conf_dir` sets another directory for the unit file.

### Environment

The service gets these variables, in this order:

1. `RAILS_ENV`, from `:rails_env`, or from `:stage` when `:rails_env` isn't set.
2. Capistrano's `default_env`, except `PATH`. Each value is expanded by the server shell, as in Capistrano commands (`$HOME`…).
3. `MALLOC_ARENA_MAX=2`.
4. `:solid_queue_service_unit_env_vars`, written as is in `Environment="…"` lines.

A later line overrides an earlier one, so `:solid_queue_service_unit_env_vars` can override any of the above. The files of `:solid_queue_service_unit_env_files` (`EnvironmentFile=` lines) override all of them. systemd doesn't start the service when one of these files is missing, unless its path starts with `-`.

```ruby
set :solid_queue_service_unit_env_vars, ["MALLOC_ARENA_MAX=4"]
set :solid_queue_service_unit_env_files, ["/var/www/my_app/shared/.env", "-/etc/default/my_app"]
```

When they aren't set, the `:service_unit_env_vars` and `:service_unit_env_files` variables, also read by capistrano3-puma and capistrano-sidekiq, are used.

Solid Queue reads the options of `bin/jobs` from environment variables too, for instance:

```ruby
set :solid_queue_service_unit_env_vars, ["SOLID_QUEUE_CONFIG=config/calendar.yml", "SOLID_QUEUE_SKIP_RECURRING=true"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codeur/capistrano-solid_queue.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Capistrano::SolidQueue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codeur/capistrano-solid_queue/blob/main/CODE_OF_CONDUCT.md).

## Credits

The structure and code of the gem are heavily inspired by [`capistrano-good_job`](https://github.com/mtomov/capistrano-good-job)'s [`systemd` tasks](https://github.com/seuros/capistrano-puma/blob/master/lib/capistrano/tasks/systemd.rake)
and [(How I) Deploy Solid Queue with Capistrano](https://world.hey.com/robzolkos/how-i-deploy-solid-queue-with-capistrano-487b4a31) article from [Rob Zolkos](https://world.hey.com/robzolkos).
