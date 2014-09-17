module Robotstxt
  class Getter
    include CommonMethods

    # Get the text of a robots.txt file from the given source, see #get.
    def obtain(source, robot_id, options)
      options = {
        :num_redirects => 5,
        :http_timeout => 10,
        :url_charset => "utf8"
      }.merge(options)

      robotstxt = if source.is_a? Net::HTTP
        obtain_via_http(source, "/robots.txt", robot_id, options)
      else
        uri = objectify_uri(source)
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = options[:http_timeout]
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        obtain_via_http(http, "/robots.txt", robot_id, options)
      end
    end

    protected

    # Recursively try to obtain robots.txt following redirects and handling the
    # various HTTP response codes as indicated on robotstxt.org
    def obtain_via_http(http, uri, robot_id, options)
      response = http.get(uri, {'User-Agent' => robot_id})

      begin
        case response
        when Net::HTTPSuccess
          decode_body(response, options[:url_charset])
        when Net::HTTPRedirection
          if options[:num_redirects] > 0 && response['location']
            options[:num_redirects] -= 1
            obtain(response['location'], robot_id, options)
          else
            all_allowed
          end
        when Net::HTTPUnauthorized
          all_forbidden
        when Net::HTTPForbidden
          all_forbidden
        else
          all_allowed
        end
      rescue Timeout::Error #, StandardError
        all_allowed
      end

    end

    # A robots.txt body that forbids access to everywhere
    def all_forbidden
      "User-agent: *\nDisallow: /\n"
    end

    # A robots.txt body that allows access to everywhere
    def all_allowed
      "User-agent: *\nDisallow:\n"
    end

    # Decode the response's body according to the character encoding in the HTTP
    # headers.
    # In the case that we can't decode, Ruby's laissez faire attitude to encoding
    # should mean that we have a reasonable chance of working anyway.
    def decode_body(response, charset)
      return nil if response.body.nil?
      Iconv.conv(charset, (response.type_params['charset'] || "ISO-8859-1"), response.body)
    rescue NameError # iconv does not exist in Ruby 2+
      response.body.encode('UTF-8', :invalid => :replace, :replace => '').encode('UTF-8')
    rescue Iconv::IllegalSequence, Iconv::InvalidCharacter, Iconv::InvalidEncoding
      response.body
    end


  end

end
