# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
  # windows server 2019 core
  # config.vm.box = "gusztavvargadr/windows-server"
  # config.vm.box_version = "1809.0.1904"
  config.vm.box = "windows-2022-amd64-virtualbox.box"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "MetaTrader"

    vb.gui = true

    # Tweak these to fit your needs.
    vb.memory = "10240"
    vb.cpus = "4"
  end

  # mount this project directory to c:\vagrant
  config.vm.synced_folder "./", "c:/vagrant"

  # mount metatrader source code project into c:\MQL
  config.vm.synced_folder "/Users/russellsherman/src/github.com/russelltsherman/metatrader", "c:/MQL"

  # copy our rsa key to guest
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "c:/Users/vagrant/.ssh/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "c:/Users/vagrant/.ssh/id_rsa.pub"
  # this should allow for direct checkout of application to guest and pushing commits from guest to github

  config.vm.provision "user-data", type: "shell", path: "provision.ps1", upload_path: "c:/vagrant/provision.ps1", privileged: true
end
