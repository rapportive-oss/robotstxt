$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'robotstxt'
require 'cgi'

class TestParser < Test::Unit::TestCase

  def test_basics
    client = Robotstxt::Parser.new("Test", <<-ROBOTS
User-agent: *
Disallow: /?*\t\t\t#comment
Disallow: /home
Disallow: /dashboard
Disallow: /terms-conditions
Disallow: /privacy-policy
Disallow: /index.php
Disallow: /chargify_system
Disallow: /test*
Disallow: /team*     # comment
Disallow: /index
Allow: /    # comment
Sitemap: http://example.com/sitemap.xml
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
    assert ["http://example.com/sitemap.xml"] == client.sitemaps

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
   #comments
Disallow: /*.pdf$
ROBOTSTXT
)
    assert true == google.allowed?("/.pdfs/index.html")
    assert false == google.allowed?("/.pdfs/index.pdf")
    assert false == google.allowed?("/.pdfs/index.pdf?action=view")
    assert false == google.allowed?("/.pdfs/index.html?download_as=.pdf")
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

  def test_missing_useragent
    robotstxt = <<-ROBOTS
Disallow: /index
ROBOTS
    assert true === Robotstxt::Parser.new("Google", robotstxt).allowed?("/hello")
    assert false === Robotstxt::Parser.new("Google", robotstxt).allowed?("/index/wold")
  end

  def test_strange_newlines
    robotstxt = "User-agent: *\r\r\rDisallow: *"
    assert false === Robotstxt::Parser.new("Google", robotstxt).allowed?("/index/wold")
  end

  def test_bad_unicode
    robotstxt = "User-agent: *\ndisallow: /?id=%C3%CB%D1%CA%A4%C5%D4%BB%C7%D5%B4%D5%E2%CD\n"
    assert true ===Robotstxt::Parser.new("Google", robotstxt).allowed?("/index/wold")
  end

end
