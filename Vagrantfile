# -*- mode: ruby -*-
# vi: set ft=ruby :

#raise "vagrant-vbguest plugin must be installed" unless Vagrant.has_plugin? "vagrant-reload"
required_plugins = %w(vagrant-reload)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|  

  def provisioning(config, shell_arguments)
    config.vm.provision "shell", path: "vagrant-scripts/provision.cmd", args: shell_arguments
  end


  config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "128"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.name = "win2008r2"   
  end  

  config.vm.boot_timeout = 600

  config.vm.define "win2k8r2_dev" do|win2k8r2_dev|
    win2k8r2_dev.vm.box = "redbull05689/2008r2"
    # win2k8r2_dev.vm.box_url = "https://vagrantcloud.com/redbull05689/2008r2"
    # win2k8r2_dev.vm.box_version = "0.1"
    win2k8r2_dev.vm.guest = :windows
    
    win2k8r2_dev.vm.communicator = "winrm"
    
    win2k8r2_dev.vm.network "private_network", ip: "192.168.123.123"
    win2k8r2_dev.vm.network :forwarded_port, guest: 1025, host: 1025
    win2k8r2_dev.vm.network :forwarded_port, guest: 3389, host: 1234
    win2k8r2_dev.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    win2k8r2_dev.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", disabled: false
   
	  provisioning(win2k8r2_dev, ["win2k8r2_dev", "win2k8r2_dev"])

    win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/setup-winrm.cmd"  

    # synced folder
    win2k8r2_dev.vm.synced_folder "./shared", "/host_shared"
    win2k8r2_dev.vm.synced_folder "./src", "/src"
    # .NET 4.5
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-dot-net.ps1"  
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-dot-net-45.cmd"
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-msbuild-tools-2013.cmd"

    # Database
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-sql-server.cmd" 
    win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/configure-sql-server.ps1"  
    
    # #Restore DB
    win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/create-database.cmd"
     
    # IIS   
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-iis.cmd"

    # Install update Windows6.1-KB2506143-x64  and choco pkg manager
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/install-update-KB2506143.cmd"

    #Create Website
    win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/copy-website.ps1"
    
    
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/creating-website-in-iis.cmd"
    # win2k8r2_dev.vm.provision :shell, path: "vagrant-scripts/setup-permissions-for-website-folder.ps1"
              
  end
end