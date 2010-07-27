$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'robotstxt'

class TestParser < Test::Unit::TestCase
  
  def setup
    @client = Robotstxt::Parser.new('rubytest')
    @client.get('http://www.simonerinzivillo.it')
  end
  
  def test_initialize
    client = Robotstxt::Parser.new('*')
    assert_instance_of Robotstxt::Parser, client
  end  
  
  def test_get_file_robotstxt
    assert @client.get('http://www.simonerinzivillo.it')
    end
  
  def test_robotstxt_isfound
    assert @client.found?()
    end
  
  def test_url_allowed
    assert true ==  @client.allowed?('http://www.simonerinzivillo.it/')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/no-dir/')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/foo-no-dir/')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/foo-no-dir/page.html')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/dir/page.php')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/page.php?var=0')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/dir/page.php?var=0')
    assert true == @client.allowed?('http://www.simonerinzivillo.it/blog/')
    assert true == @client.allowed?('http://www.simonerinzivillo.it/blog/page.php')
    assert false == @client.allowed?('http://www.simonerinzivillo.it/blog/page.php?var=0')
    end
  
  def test_sitemaps
    assert @client.sitemaps.length() > 0
    end

  def test_sitemap
    client = Robotstxt::Parser.new("Test", <<-ROBOTS
User-agent: *
Disallow: /?*
Disallow: /home
Disallow: /dashboard
Disallow: /terms-conditions
Disallow: /privacy-policy
Disallow: /index.php
Disallow: /chargify_system
Disallow: /test*
Disallow: /team*
Disallow: /index
Allow: /
Sitemap: http://chargify.com/sitemap.xml
ROBOTS
)
    assert true == client.allowed?("/")
    assert false == client.allowed?("/?")
    assert false == client.allowed?("/?key=value")
    assert true == client.allowed?("/example")
    assert true == client.allowed?("/example/index.php")
    assert false == client.allowed?("/test")
    assert false == client.allowed?("/test/example")
    assert false == client.allowed?("/team-game")
    assert false == client.allowed?("/team-game/example")

  end

  def test_useragents
    robotstxt = <<-ROBOTS
User-agent: Google
Disallow:

User-agent: *
Disallow: /
ROBOTS
    assert true == Robotstxt::Parser.new("Google", robotstxt).allowed?("/hello")
    assert false == Robotstxt::Parser.new("Bing", robotstxt).allowed?("/hello")
  end
  
end
