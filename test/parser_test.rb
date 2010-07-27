$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'robotstxt'

class TestParser < Test::Unit::TestCase
  
  def test_basics
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

  def test_blank_disallow
    google = Robotstxt::Parser.new("Google", <<-ROBOTSTXT
User-agent: *
Disallow:
ROBOTSTXT
                                  )
    assert true == google.allowed?("/")
    assert true == google.allowed?("/index.html")
  end

  def test_url_escaping
    google = Robotstxt::Parser.new("Google", <<-ROBOTSTXT
User-agent: *
Disallow: /test/
Disallow: /secret%2Fgarden/
Disallow: /%61lpha/
ROBOTSTXT
)
    assert true == google.allowed?("/allowed/")
    assert false == google.allowed?("/test/")
    assert true == google.allowed?("/test%2Fetc/")
    assert false == google.allowed?("/secret%2fgarden/")
    assert true == google.allowed?("/secret/garden/")
    assert false == google.allowed?("/alph%61/")
  end

  def test_trail_matching
    google = Robotstxt::Parser.new("Google", <<-ROBOTSTXT
User-agent: *
Disallow: /*.pdf$
ROBOTSTXT
)
    assert true == google.allowed?("/.pdfs/index.html")
    assert false == google.allowed?("/.pdfs/index.pdf")
    assert false == google.allowed?("/.pdfs/index.pdf?action=view")
  end

  def test_useragents
    robotstxt = <<-ROBOTS
User-agent: Google
User-agent: Yahoo
Disallow:

User-agent: *
Disallow: /
ROBOTS
    assert true == Robotstxt::Parser.new("Google", robotstxt).allowed?("/hello")
    assert true == Robotstxt::Parser.new("Yahoo", robotstxt).allowed?("/hello")
    assert false == Robotstxt::Parser.new("Bing", robotstxt).allowed?("/hello")
  end
  
end
