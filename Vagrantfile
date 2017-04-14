#-*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

$cassandra = 1
$cassandra_vm_memory = 2048
$opscenter = 0
$opscenter_vm_memory = 1024

$tb = "en4: Thunderbolt Ethernet"
$wifi = "en0: Wi-Fi (AirPort)"


def nodeIP(num)
  return "192.168.60.#{num+99}"
end

def opscenterIP(num)
  return "192.168.60.#{num+49}"
end

# Create hosts file for all nodes
hosts_file = Tempfile.new('hosts.txt')
(1..$cassandra).each do |i|
  hosts_file.write("%s %s %s %s\n" % [nodeIP(i), "node%d" % i, "cassandra%d" % i, "cassandra%d.vagrant.local" % i ])
end
hosts_file.close

VAGRANT_API_VERSION = 2

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.provider :virtualbox do |vb|
    vb.cpus = 2
    vb.gui = false
  end

  (1..$cassandra).each do |i|

  end

  ############################
  #  CASSANDRA
  ############################

  (1..$cassandra).each do |i|

    config.vm.define vm_name = "cassandra%d" % i do |cassandra|

      cassandra.vm.hostname = vm_name

      cassandra.vm.provider :virtualbox do |vb|
        vb.memory = $cassandra_vm_memory
      end
      cassandra.vm.network "private_network", ip: nodeIP(i)
      # , virtualbox__intnet: true
      cassandra.vm.provision :file, :source => hosts_file, :destination => "/vagrant/vm-provisions/hosts.txt"
      cassandra.vm.provision :shell, :inline => "sed -ri 's/=none/=static/' /etc/sysconfig/network-scripts/ifcfg-eth1", :privileged => true
      cassandra.vm.provision :shell, :inline => "systemctl restart network", :privileged => true
      cassandra.vm.provision :shell, :inline => "cd /vagrant/vm-provisions && ./node-bootstrap.sh", :privileged => true

     end
  end

  ############################
  #  OPS CENTER
  ############################

  (1..$opscenter).each do |i|

    config.vm.define vm_name = "opscenter%d" % i do |opscenter|

      opscenter.vm.hostname = vm_name

      opscenter.vm.provider :virtualbox do |vb|
        vb.memory = $cassandra_vm_memory
      end

      opscenter.vm.network "private_network", ip: opscenterIP(i), virtualbox__intnet: false
      opscenter.vm.provision :shell, :inline => "cd /vagrant/vm-provisions && ./opscenter-bootstrap.sh", :privileged => true

     end
  end

end
