module Infor
  module REST
    class HierarchyNodes < ListResource

      def initialize(client, path='/hierarchies/nodes')
        super
      end

      def hi
        puts "Hello HierarchyNodes World!, path=#{path}"
      end

    end
  end
end
