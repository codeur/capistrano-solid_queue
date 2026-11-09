# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "capistrano/solid_queue"

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

module CapistranoProject
  def run_cap(task, stage_config: "")
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

      output, status = Open3.capture2e(RbConfig.ruby, Gem.bin_path("capistrano", "cap"), "preprod", task, chdir: dir)
      yield output, status, dir
    end
  end
end
