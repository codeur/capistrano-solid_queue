# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

class Capistrano::TestServiceUnit < Minitest::Test
  def test_rails_env_is_capistrano_rails_env
    unit = generate_unit(stage_config: 'set :rails_env, "production"')

    assert_includes unit, "Environment='RAILS_ENV=production'"
  end

  def test_rails_env_defaults_to_stage
    unit = generate_unit

    assert_includes unit, "Environment='RAILS_ENV=preprod'"
  end

  private

  def generate_unit(stage_config: "")
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "config", "deploy"))
      File.write(File.join(dir, "Capfile"), <<~RUBY)
        require "capistrano/setup"
        require "capistrano/deploy"
        require "capistrano/scm/git"
        install_plugin Capistrano::SCM::Git
        require "capistrano/solid_queue"
        install_plugin Capistrano::SolidQueue::Systemd
      RUBY
      File.write(File.join(dir, "config", "deploy.rb"), <<~RUBY)
        set :application, "app"
        set :deploy_to, "/var/www/app"
        set :sshkit_backend, SSHKit::Backend::Local
      RUBY
      File.write(File.join(dir, "config", "deploy", "preprod.rb"), <<~RUBY)
        server "localhost", roles: %w[db]
        #{stage_config}
      RUBY

      output, status = Open3.capture2e(RbConfig.ruby, Gem.bin_path("capistrano", "cap"), "preprod", "solid_queue:generate", chdir: dir)
      assert status.success?, output

      File.read(File.join(dir, "solid_queue.service"))
    end
  end
end
