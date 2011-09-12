require 'uri'
require 'iconv'
require 'net/http'

module Robotstxt
  module CommonMethods

    protected
    # Convert a URI or a String into a URI
    def objectify_uri(uri)

        if uri.is_a? String
          # URI.parse will explode when given a character that it thinks
          # shouldn't appear in uris. We thus escape them before passing the
          # string into the function. Unfortunately URI.escape does not respect
          # all characters that have meaning in HTTP (esp. #), so we are forced
          # to state exactly which characters we would like to escape.
          uri = URI.escape(uri, %r{[^!$#%&'()*+,\-./0-9:;=?@A-Z_a-z~]})
          uri = URI.parse(uri)
        else
          uri
        end

    end
  end
end
