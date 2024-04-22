# Capistrano Systemd integration for SolidQueue

Adds the following capistrano commands:

```sh
solid_queue:generate                   # Generate locally solid_queue systemd service unit file
solid_queue:disable                    # Disable solid_queue systemd service
solid_queue:enable                     # Enable solid_queue systemd service
solid_queue:install                    # Install solid_queue systemd service
solid_queue:reload                     # Reload solid_queue service via systemd
solid_queue:quiet                      # Quiet solid_queue service via systemd
solid_queue:restart                    # Restart solid_queue service via systemd
solid_queue:start                      # Start solid_queue service via systemd
solid_queue:status                     # Get solid_queue service status via systemd
solid_queue:stop                       # Stop solid_queue service via systemd
solid_queue:uninstall                  # Uninstall solid_queue systemd service
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

install_plugin Capistrano::SolidQueue, load_hooks: false
```

Then run once

```sh
bundle exec cap production solid_queue:install
```

for the initial setup. This will copy a [`systemd` service definition](lib/capistrano/templates/solid_queue.service.erb) to `~/.config/systemd/user/<application>_solid_queue_<stage>.service` on your server marked with Capistrano role `db`.

It will also `enable` it in `systemd`, allowing to to then run commands such as:

```sh
systemctl --user status your_app_solid_queue_production
systemctl --user start your_app_solid_queue_production
systemctl --user stop your_app_solid_queue_production
systemctl --user reload your_app_solid_queue_production
systemctl --user restart your_app_solid_queue_production
```

through their Capistrano counterparts, ex: `bundle exec cap solid_queue:restart`.

## Usage

The plugin has registered a Capistrano `hook` to run `bundle exec cap solid_queue:restart` after deploy.
See [`#register_hooks`](lib/capistrano/solid_queue.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codeur/capistrano-solid_queue.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Capistrano::SolidQueue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/capistrano-solid_queue/blob/main/CODE_OF_CONDUCT.md).

## Credits

The structure and code of the gem are heavily inspired by [`capistrano-good_job`](https://github.com/mtomov/capistrano-good-job)'s [`systemd` tasks](https://github.com/seuros/capistrano-puma/blob/master/lib/capistrano/tasks/systemd.rake)
and [(How I) Deploy Solid Queue with Capistrano](https://world.hey.com/robzolkos/how-i-deploy-solid-queue-with-capistrano-487b4a31) article.
