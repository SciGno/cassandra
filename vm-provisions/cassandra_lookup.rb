require 'cassandra'

cluster = Cassandra.cluster(
	:hosts => ['192.168.60.101'],
	:load_balancing_policy => Cassandra::LoadBalancing::Policies::DCAwareRoundRobin.new("DC1")
	)

cluster.each_host do |host|
	puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
end

keyspace = 'hiera'
session = cluster.connect(keyspace)

args = ['global', 'name']

statement = session.prepare("SELECT value FROM value_by_source WHERE source=? AND key=?")

result = session.execute(statement, arguments: args)

if result.length == 0 then
	puts 'Not found!!!'
else
	puts "Size: #{result.length}"
	result.each do |row|
		puts row
		puts row['value']
	end
end

