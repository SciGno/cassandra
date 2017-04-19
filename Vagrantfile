# -*- mode: ruby -*-
# vi: set ft=ruby :

$cassandra = 1
$cassandra_mem = 1024
$cassandra_cpu = 1
$ip_prefix = "192.168.50."

def nodeIP(num)
  return "#{$ip_prefix}#{num+99}"
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"
  # config.vm.define vm_name = "cassandra"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  (1..$cassandra).each do |i|

    config.vm.define vm_name = "cassandra%d" % i do |cassandra|

      cassandra.vm.hostname = vm_name
      cassandra.vm.provider :virtualbox do |vb|
        vb.memory = $cassandra_mem
        vb.cpus = $cassandra_cpu
        vb.gui = false
      end
      cassandra.vm.network "private_network", ip: nodeIP(i)
      # , virtualbox__intnet: true
      # cassandra.vm.provision :file, :source => hosts_file, :destination => "/vagrant/vm-provisions/hosts.txt"
      # cassandra.vm.provision :shell, :inline => "sed -ri 's/=none/=static/' /etc/sysconfig/network-scripts/ifcfg-eth1", :privileged => true
      # cassandra.vm.provision :shell, :inline => "systemctl restart network", :privileged => true
      # cassandra.vm.provision :shell, :inline => "cd /vagrant/vm-provisions && ./node-bootstrap.sh", :privileged => true

      cassandra.vm.provision "shell", :privileged => true, inline: <<-SHELL
      echo Updating linux ...
      time yum -y -q update
      echo Installing tool packages ...
      time yum -y -q install net-tools bind-utils wget nc curl strace tcpdump java-1.8.0-openjdk
      USER=cassandra
      GROUP=cassandra
      PKG=datastax-ddc-3.9.0-bin.tar.gz
      DIR=/opt/datastax-ddc-3.9.0

      echo Modifying /etc/hosts file ...
      MY_IP=`ifconfig | grep 192.168 | awk '{print $2}'`
      for i in $(seq 1 #{$cassandra})
      do
        echo "#{$ip_prefix}"$((99 + $i)) node$i cassandra$i cassandra$i.vagrant.local >> /etc/hosts
      done
      cat /etc/hosts

      echo Creating Cassandra user and group ...
      useradd cassandra
      echo Password1 | passwd $USER --stdin
      echo Password1 | passwd root --stdin

      echo Downloading Cassandra ...
      time wget -q http://downloads.datastax.com/datastax-ddc/datastax-ddc-3.9.0-bin.tar.gz

      echo Installing Cassandra ...
      tar xfz $PKG -C /opt
      chown -R $USER:$GROUP $DIR

      echo Applying configuration ...
      sed -i -e "s/^cluster_name:.*/cluster_name: 'Experian'/" $DIR/conf/cassandra.yaml
      sed -i -e "s/^num_tokens:.*/num_tokens: 256/" $DIR/conf/cassandra.yaml
      sed -i -e "s/ seeds:.*/ seeds: 'node1'/" $DIR/conf/cassandra.yaml
      echo listen_address: $MY_IP
      sed -i -e "s/^listen_address:.*$/listen_address: $MY_IP/" $DIR/conf/cassandra.yaml
      echo broadcast_address: $MY_IP
      sed -i -e "s/^.*broadcast_address:.*$/broadcast_address: $MY_IP/" $DIR/conf/cassandra.yaml
      echo rpc_address: $MY_IP
      sed -i -e "s/^rpc_address:.*$/rpc_address: $MY_IP/" $DIR/conf/cassandra.yaml
      echo broadcast_rpc_address: $MY_IP
      sed -i -e "s/^.*broadcast_rpc_address:.*$/broadcast_rpc_address: $MY_IP/" $DIR/conf/cassandra.yaml
      sed -i -e "s/^endpoint_snitch:.*$/endpoint_snitch: GossipingPropertyFileSnitch/" $DIR/conf/cassandra.yaml
      sed -i -e "s/^start_rpc:.*$/start_rpc: true/" $DIR/conf/cassandra.yaml

      echo Setting DC/RAC details ...
      cat << EOF > $DIR/conf/cassandra-rackdc.properties
      dc=DC1
      rack=RAC1
      EOF
      SHELL
    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.50.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = false
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  #   vb.cpus = 1
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  # yum update -y
  # yum install -y net-tools nc bind-utils wget curl git
  # SHELL

  echo Starting Cassandra
  su -c $DIR/bin/cassandra - cassandra
end
