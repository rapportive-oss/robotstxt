#
# = Ruby Robotstxt
#
# An Ruby Robots.txt parser.
#
#
# Category::    Net
# Package::     Robotstxt
# Author::      Simone Rinzivillo <srinzivillo@gmail.com>
# License::     MIT License
#
#--
#
#++

require 'net/http'
require 'uri'


module Robotstxt
  class Parser
    attr_accessor :robot_id
    attr_reader :found, :body, :sitemaps, :rules
    
    # Initializes a new Robots::Robotstxtistance with <tt>robot_id</tt> option.
    #
    # <tt>client = Robotstxt::Robotstxtistance.new('my_robot_id')</tt>
    #
    def initialize(robot_id = nil, body = nil)
      
      @robot_id = '*'
      @rules = []
      @sitemaps = []
      @robot_id = robot_id.downcase if !robot_id.nil?
      if body
        @body = body
        parse
      end
    end
    
    
    # Requires and parses the Robots.txt file for the <tt>hostname</tt>.
    #
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  client.get('http://www.simonerinzivillo.it')
    #
    #  
    # This method returns <tt>true</tt> if the parsing is gone.
    #  
    def get(hostname)
      
      @ehttp = true
      url = URI.parse(hostname)
      
      begin
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme == 'https'
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.use_ssl = true 
        end
        
        response =  http.request(Net::HTTP::Get.new('/robots.txt'))
        
        case response
          when Net::HTTPSuccess then
          @found = true
          @body = response.body
          parse()    
          
          else
          @found = false
        end 
        
        return @found
        
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET => e
        if @ehttp
          @ettp = false
          retry 
          else
          return nil
        end
      end
      
    end
    
    
    # Check if the <tt>URL</tt> is allowed to be crawled from the current Robot_id.
    # 
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  if client.get('http://www.simonerinzivillo.it')
    #    client.allowed?('http://www.simonerinzivillo.it/no-dir/')
    #  end
    #
    # This method returns <tt>true</tt> if the robots.txt file does not block the access to the URL.
    #
    # Rules are matched in the order they appear in robots.txt
    # See http://www.robotstxt.org/orig.html and http://www.robotstxt.org/norobots-rfc.txt
    # (and a high level overview at http://www.robotstxt.org/robotstxt.html)
    def allowed?(var)
      url = URI.parse(var)
      url_path = (url.path || '/' ) + (url.query ? '?' + url.query : '')
      
      @rules.each do |(ua_glob, path_globs)|

        if match_glob @robot_id, ua_glob
          path_globs.each do |(path_glob, allowed)|
            return allowed if match_glob url_path, path_glob
          end
        end

      end
      true
    end
    
    # Analyze the robots.txt file to return an <tt>Array</tt> containing the list of XML Sitemaps URLs.
    # 
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  if client.get('http://www.simonerinzivillo.it')
    #    client.sitemaps.each{ |url|
    #    puts url
    #  }
    #  end  
    #
    def sitemaps
      @sitemaps
    end
    
    # This method returns <tt>true</tt> if the Robots.txt parsing is gone.
    #
    def found?
      !!@found
    end
    
    
    private

    # Robots.txt doesn't seem to have an official standard that is widely used.
    # As Google provide clear documentation, and are somewhat of a market-leader
    # I'll follow their syntax at:
    # http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=156449
    #
    # A * matches any sequence of characters, all other characters are literals.
    # A trailing $ forces the pattern to be matched entirely, otherwise it's a prefix match.
    #
    # Other search engines seem to only interpret * and $ in certain circumstances, ick.
    def match_glob(string, glob)
      suffix = (glob =~ /\$$/ ? "$" : "")
      expression = glob.split("*").map{|x| Regexp.escape(x) }.join(".*")
      string =~ Regexp.new("^" + expression + suffix, "i")
    end
    
    # Convert the @body into a set of @rules so that our parsing mechanism
    # becomes easier.
    #
    # @rules is an array of pairs. The first in the pair is the glob for the user-agent
    # and the second another array of pairs. The first of the new pair is a glob for
    # the path, and the second whether it appears in an Allow: or a Disallow: rule.
    #
    # For example:
    #
    # User-agent: *
    # Allow: /
    # Disallow: /secret/
    #
    # Would be parsed so that:
    #
    # @rules = [["*", [
    #  ["/", true],
    #  ["/secret/", false]
    # ]]]
    #
    #
    # The order of the arrays is maintained so that the first match in the file
    # is obeyed. As indicated by the pseudo-RFC on http://robotstxt.org/
    #
    # There is one subtlety in that a blank Disallow: should be treated as an Allow: *
    def parse()
      
      @body.each_line do |line| 

        prefix, value = line.split(":", 2).map(&:strip)
        
        if prefix && value
          case prefix.capitalize
            when /^User-?agent$/
              @rules << [value, []]

            when "Disallow"
              if rules.any?
                if value == ""
                  @rules.last[1] << ["*", true]
                else
                  @rules.last[1] << [value, false]
                end
              end

            when "Allow"
              @rules.last[1] << [value, true] if @rules.any?

            when "Sitemap"
              @sitemaps << value

            else
              # Ignore comments and badly formed lines.

          end
        end
      end
    end
  end
end
