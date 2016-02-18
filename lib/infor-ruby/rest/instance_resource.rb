module Infor
  module REST
    class InstanceResource

      def initialize(path, client, params = {})
        @path, @client = path, client
        set_up_properties_from params
      end

      def inspect
        "<#{self.class} @path=#{@path}>"
      end

      def update(params = {})
        raise "Can't update a resource without a REST Client" unless @client
        set_up_properties_from(@client.post(@path, params))
        self
      end

      def refresh
        raise "Can't refresh a resource without a REST Client" unless @client
        @updated = false
        set_up_properties_from(@client.get(@path))
        self
      end

      def delete
        raise "Can't delete a resource without a REST Client" unless @client
        @client.delete @path
      end

      protected

      def set_up_properties_from(hash)
        eigenclass = class << self; self; end
        hash.each do |p,v|
          property = detwilify p
          unless ['client', 'updated'].include? property
            eigenclass.send :define_method, property.to_sym, &lambda { v }
          end
        end
        @updated = !hash.keys.empty?
      end
    end
  end
end
