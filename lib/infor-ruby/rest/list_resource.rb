module Infor
  module REST
    class ListResource

      attr_reader :path

      def initialize(client, path)
        custom_names = {
          'Activities' => 'Activity',
          'Addresses' => 'Address',
          'Countries' => 'Country',
          'Feedback' => 'FeedbackInstance',
          'IpAddresses' => 'IpAddress',
          'Media' => 'MediaInstance',
        }
        @client, @path = client, path
        resource_name = self.class.name.split('::')[-1]
        instance_name = custom_names.fetch(resource_name, resource_name.chop)
      end

       def list(params={}, full_path=false)
        raise "Can't get a resource list without a REST Client" unless @client
        response = @client.get @path, params, full_path
        puts "response = #{response.inspect}"
        resources = response[@list_key]
        path = full_path ? @path.split('.')[0] : @path
        resource_list = resources.map do |resource|
          @instance_class.new "#{path}/#{resource[@instance_id_key]}", @client,
            resource
        end
        # set the +previous_page+ and +next_page+ properties on the array
        client, list_class = @client, self.class
        resource_list.instance_eval do
          eigenclass = class << self; self; end
          eigenclass.send :define_method, :previous_page, &lambda {
            if response['previous_page_uri']
              list_class.new(response['previous_page_uri'], client).list({}, true)
            else
              []
            end
          }
          eigenclass.send :define_method, :next_page, &lambda {
            if response['next_page_uri']
              list_class.new(response['next_page_uri'], client).list({}, true)
            else
              []
            end
          }
        end
        resource_list
      end

      def get(sid)
      end
      alias :find :get # for the ActiveRecord lovers

      def create(params={})
        raise "Can't create a resource without a REST Client" unless @client
      end

      private

        def perform_get(route, data)
          https = Net::HTTP.new(@client.host, @client.port)
          https.use_ssl = @client.use_ssl

          request = Net::HTTP::Get.new(route)

          request["Content-Type"] = 'application/json'

          request.body = data

          response = https.request(request)
          [response.code.to_i, JSON.parse(response.body)]
        end
    end
  end
end