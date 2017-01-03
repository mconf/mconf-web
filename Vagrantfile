# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "lxc" do |v, override|
    override.vm.box = "fgrehm/trusty64-lxc"
  end

  config.vm.box_download_insecure = true

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  # For Mailcatcher
  config.vm.network :forwarded_port, guest: 1025, host: 1025
  config.vm.network :forwarded_port, guest: 1080, host: 1080

  # To share other directories e.g. local gems
  # config.vm.synced_folder '../bigbluebutton_rails', '/bigbluebutton_rails'

  config.omnibus.chef_version = '12.0.3'

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks", "cookbooks-local"]
    # chef.log_level = :debug

    chef.add_recipe "apt"
    chef.add_recipe "git"
    chef.add_recipe "vim"
    chef.add_recipe "mconf-web-dev"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::user"
    chef.add_recipe "rbenv::vagrant"
    chef.add_recipe "mysql::server"
    chef.add_recipe "mysql::client"
    chef.add_recipe "redisio"
    chef.add_recipe "redisio::enable"

    # Install ruby and bundler
    # Set an empty root password for MySQL to make things simple
    rb_version = IO.read(File.join(File.dirname(__FILE__), '.ruby-version')).chomp
    chef.json = {
      rbenv: {
        git_ref: 'master',
        user_installs: [{
          user: 'vagrant',
          rubies: [rb_version],
          global: rb_version,
          gems: {
            rb_version => [
              { name: "bundler" }
            ]
          },
          plugins: [
            { 'name' => 'ruby-build',
              'git_url' => 'https://github.com/rbenv/ruby-build.git' }
          ]
        }]
      },
      mysql: {
        server_root_password: ''
      }
    }
  end
end
