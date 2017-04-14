#!/bin/bash

# https://speakerdeck.com/avalanche123/ruby-driver-explained

VM_PROVISIONS=/vagrant/vm-provisions
USER=cassandra
GROUP=cassandra
# PKG=apache-cassandra-2.2.6-bin.tar.gz
# DIR=/opt/apache-cassandra-2.2.6
PKG=datastax-ddc-3.9.0-bin.tar.gz
DIR=/opt/datastax-ddc-3.9.0
# sed -ri "s/=none/=static/" /etc/sysconfig/network-scripts/ifcfg-eth1
# systemctl restart network

# cd $VM_PROVISIONS

echo Modifying /etc/hosts file ...
cat $VM_PROVISIONS/hosts.txt >> /etc/hosts

MY_IP=`grep $HOSTNAME.vagrant.local /etc/hosts | awk '{print $1}'`

echo Installing tool packages ...
yum install -y net-tools bind-utils wget nc htop strace tcpdump

echo Installing JDK 8 ...
rpm -Uvh $VM_PROVISIONS/jdk-8u92-linux-x64.rpm

echo Creating Cassandra user and group ...
useradd cassandra
echo Password1 | passwd $USER --stdin
echo Password1 | passwd root --stdin

# mkdir -p /var/lib/cassandra && chown -R  $USER:$GROUP /var/lib/cassandra
# mkdir -p /var/log/cassandra && chown -R  $USER:$GROUP /var/log/cassandra
# mkdir -p /var/lib/spark && chown -R  $USER:$GROUP /var/lib/spark
# mkdir -p /var/log/spark && chown -R  $USER:$GROUP /var/log/spark

# echo Downloading Cassandra ...
# wget http://downloads.datastax.com/datastax-ddc/datastax-ddc-3.5.0-bin.tar.gz

# echo Installing DataStax Cassandra ...
# tar xfz $VM_PROVISIONS/datastax-ddc-3.5.0-bin.tar.gz -C /opt
# tar xfz $VM_PROVISIONS/opscenter-5.2.4.tar.gz -C /opt
# chown -R $USER:$GROUP /opt/datastax-ddc-3.5.0
# chown -R $USER:$GROUP /opt/opscenter-5.2.4

echo Installing Cassandra ...
tar xfz $VM_PROVISIONS/$PKG -C /opt
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

echo Starting Cassandra
su -c $DIR/bin/cassandra - cassandra
sleep 20
