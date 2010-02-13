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
		def initialize(robot_id = nil)
			
			@robot_id = '*'
			@rules = []
			@sitemaps = []
			@robot_id = robot_id.downcase if !robot_id.nil?
			
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
		def allowed?(var)
			is_allow = true
			url = URI.parse(var)
			querystring = (!url.query.nil?) ? '?' + url.query : ''
			url_path = url.path + querystring
			
			@rules.each {|ua|
				
				if @robot_id == ua[0] || ua[0] == '*' 
					
					ua[1].each {|d|
						
						is_allow = false if url_path.match('^' + d ) || d == '/'
						
					}
					
				end
				
			}
			is_allow
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
		
		def parse()
			@body = @body.downcase
			
			@body.each_line {|r| 
				
				case r
					when /^#.+$/
					
					when /^\s*user-agent\s*:.+$/ 
					
					@rules << [ r.split(':')[1].strip, [], []]
					
					when /^\s*useragent\s*:.+$/
					
					@rules << [ r.split(':')[1].strip, [], []]
					
					when /^\s*disallow\s*:.+$/
					r = r.split(':')[1].strip
					@rules.last[1]<< r.gsub(/\*/,'.+') if r.length > 0 
					
					when /^\s*allow\s*:.+$/
					r = r.split(':')[1].strip
					@rules.last[2]<< r.gsub(/\*/,'.+') if r.length > 0 
					
					when /^\s*sitemap\s*:.+$/
					@sitemaps<< r.split(':')[1].strip + ((r.split(':')[2].nil?) ? '' : r.split(':')[2].strip) if r.length > 0  		
					
				end
				
			}
			
			
		end
		
	end
end