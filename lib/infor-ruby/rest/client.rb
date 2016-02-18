module Infor
  module REST
    class Client

      attr_reader :host, :port, :use_ssl, :connection, :hierarchies

      HTTP_HEADERS = {
          'Accept' => 'application/json',
          'Accept-Charset' => 'utf-8',
          'User-Agent' => "infor-ruby" \
                        " (#{RUBY_ENGINE}/#{RUBY_PLATFORM}" \
                        " #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL})"
      }

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        @host = 'localhost' || options[:host]
        @port = 9000 || options[:port]
        @use_ssl = false | options[:use_ssl]

        set_up_connection
      end

      def hierarchies
        @hierarchies ||= Infor::REST::Hierarchies.new(self)
      end

      [:get, :put, :post, :delete].each do |method|
        method_class = Net::HTTP.const_get method.to_s.capitalize
        define_method method do |path, *args|
          params = args.last.is_a?(Hash) ? args.pop : {}
          request = method_class.new(path, HTTP_HEADERS)
          puts "request=#{request.inspect}"
          request.form_data = params if [:post, :put].include?(method)
          connect_and_send(request)
        end
      end

      protected
      def set_up_connection
        @connection = Net::HTTP.new host, port
        @connection.use_ssl = use_ssl
      end

      def connect_and_send(request)
        begin
          puts "connection = #{@connection}"
          puts "request = #{request}"
          response = @connection.request request
          puts "response = #{response.inspect}"
          if response.kind_of? Net::HTTPServerError
            raise Infor::REST::ServerError
          end
        rescue Exception => e
          raise Infor::REST::ServerError.new(e.message)
        end
        if response.body and !response.body.empty?
          object = MultiJson.load response.body
        elsif response.kind_of? Net::HTTPBadRequest
          object = { message: 'Bad request', code: 400 }
        end

        if response.kind_of? Net::HTTPClientError
          raise Infor::REST::RequestError.new object['message'], object['code']
        end
        object
      end
    end
  end
end