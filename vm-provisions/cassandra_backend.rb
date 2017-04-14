class Hiera
  module Backend
    class Cassandra_backend
      def initialize(cache=nil)
        # require 'yaml'
        require 'cassandra'
        cluster = Cassandra.cluster(
          :hosts => ['192.168.60.101'],
          :load_balancing_policy => Cassandra::LoadBalancing::Policies::DCAwareRoundRobin.new("DC1")
          )
        cluster.each_host do |host|
          Hiera.debug("Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}")
        end

        keyspace = 'hiera'
        @session = cluster.connect(keyspace)
        Hiera.debug("Hiera CASSANDRA backend starting")

        @cache = cache || Filecache.new
      end

      def lookup(key, scope, order_override, resolution_type, context)
        # answer = nil
        # found = false

        Hiera.debug("Lookup information in LEO backend")
        Hiera.debug("KEY: #{key}")
        Hiera.debug("SCOPE: #{scope}")
        Hiera.debug("ORDER_OVERRIDE: #{order_override}")
        Hiera.debug("RESOLUTION TYPE: #{resolution_type}")
        Hiera.debug("CONTEXT: #{context}")

        @key = key
        @resolution_type = resolution_type

        Backend.datasources(scope, order_override) do |sources|
          Hiera.debug("Looking for data in: #{sources}")

          args = [sources, @key]

          statement = @session.prepare("SELECT value FROM value_by_source WHERE source=? AND key=?")

          result = @session.execute(statement, arguments: args)

          if result.length > 0 then
            result.each do |row|
              Hiera.debug("Found data in: #{sources}")
              return row['value']
            end
          end
          
        end
      end
    end
  end
end