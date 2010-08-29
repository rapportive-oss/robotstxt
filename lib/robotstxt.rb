#
# = Ruby Robotstxt
#
# An Ruby Robots.txt parser.
#
#
# Category::    Net
# Package::     Robotstxt
# Author::      Conrad Irwin <conrad@rapportive.com>, Simone Rinzivillo <srinzivillo@gmail.com>
# License::     MIT License
#
#--
#
#++

require 'robotstxt/common'
require 'robotstxt/parser'
require 'robotstxt/getter'

# Provides a flexible interface to help authors of web-crawlers
# respect the robots.txt exclusion standard.
#
module Robotstxt

  NAME            = 'Robotstxt'
  GEM             = 'robotstxt'
  AUTHORS         = ['Conrad Irwin <conrad@rapportive.com>', 'Simone Rinzivillo <srinzivillo@gmail.com>']
  VERSION        = '1.0'

  # Obtains and parses a robotstxt file from the host identified by source,
  # source can either be a URI, a string representing a URI, or a Net::HTTP
  # connection associated with a host.
  #
  # The second parameter should be the user-agent header for your robot.
  #
  # There are currently two options:
  #  :num_redirects (default 5) is the maximum number of HTTP 3** responses
  #   the get() method will accept and follow the Location: header before
  #   giving up.
  #  :http_timeout (default 10) is the number of seconds to wait for each
  #   request before giving up.
  #  :url_charset (default "utf8") the character encoding you will use to
  #   encode urls.
  #
  # As indicated by robotstxt.org, this library treats HTTPUnauthorized and
  # HTTPForbidden as though the robots.txt file denied access to the entire
  # site, all other HTTP responses or errors are treated as though the site
  # allowed all access.
  #
  # The return value is a Robotstxt::Parser, which you can then interact with
  # by calling .allowed? or .sitemaps. i.e.
  #
  # Robotstxt.get("http://example.com/", "SuperRobot").allowed? "/index.html"
  #
  # Net::HTTP.open("example.com") do |http|
  #   if Robotstxt.get(http, "SuperRobot").allowed? "/index.html"
  #     http.get("/index.html")
  #   end
  # end
  #
  def self.get(source, robot_id, options={})
    self.parse(Getter.new.obtain(source, robot_id, options), robot_id)
  end

  # Parses the contents of a robots.txt file for the given robot_id
  #
  # Returns a Robotstxt::Parser object with methods .allowed? and
  # .sitemaps, i.e.
  #
  # Robotstxt.parse("User-agent: *\nDisallow: /a", "SuperRobot").allowed? "/b"
  #
  def self.parse(robotstxt, robot_id)
    Parser.new(robot_id, robotstxt)
  end

  # Gets a robotstxt file from the host identified by the uri
  #  (which can be a URI object or a string)
  #
  # Parses it for the given robot_id
  #  (which should be your user-agent)
  #
  # Returns true iff your robot can access said uri.
  #
  # Robotstxt.get_allowed? "http://www.example.com/good", "SuperRobot"
  #
  def self.get_allowed?(uri, robot_id)
    self.get(uri, robot_id).allowed? uri
  end

  # DEPRECATED

  def self.allowed?(uri, robot_id); self.get(uri, robot_id).allowed? uri; end
  def self.sitemaps(uri, robot_id); self.get(uri, robot_id).sitemaps; end

end
