# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
  # windows server 2022
  # build using https://github.com/russelltsherman/packer-windows-vagrant
  config.vm.box = "windows-2022-amd64"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "MetaTrader5"
    vb.gui = true

    # Adjust these to fit your host.
    vb.memory = 1024*4
    vb.cpus = 4

    # enable audio output
    vb.customize ["modifyvm", :id, "--audio", "coreaudio"]
    vb.customize ["modifyvm", :id, "--audiocontroller", "hda"]
    vb.customize ["modifyvm", :id, "--audioout", "on"]
  end

  # mount this project directory to c:\vagrant
  config.vm.synced_folder "./", "C:/vagrant"

  # mount MetaTrader 5 source code project into C:/Users/vagrant/MQL5
  # https://github.com/russelltsherman/MQL5
  # clone this project to your local workstation and ensure the local path is correct before vagrant up
  config.vm.synced_folder "~/src/github.com/russelltsherman/MQL5", "C:/Users/vagrant/MQL5"

  config.vm.provision "user-data", type: "shell", path: "provision.ps1", upload_path: "c:/vagrant/provision.ps1", privileged: true
end
