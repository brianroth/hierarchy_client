module Infor
  module REST
    class HierarchyLevels < ListResource

      def initialize(client, path='/hierarchies')
        super
      end

      def hi
        puts "Hello HierarchyLevel World!, path=#{path}"
      end

    end
  end
end
