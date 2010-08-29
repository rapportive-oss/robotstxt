$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'robotstxt'
require 'fakeweb'

FakeWeb.allow_net_connect = false

class TestRobotstxt < Test::Unit::TestCase

  def test_absense
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :status => ["404", "Not found"])
    assert true == Robotstxt.get_allowed?("http://example.com/index.html", "Google")
  end

  def test_error
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :status => ["500", "Internal Server Error"])
    assert true == Robotstxt.get_allowed?("http://example.com/index.html", "Google")
  end

  def test_unauthorized
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :status => ["401", "Unauthorized"])
    assert false == Robotstxt.get_allowed?("http://example.com/index.html", "Google")
  end

  def test_forbidden
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :status => ["403", "Forbidden"])
    assert false == Robotstxt.get_allowed?("http://example.com/index.html", "Google")
  end

  def test_uri_object
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :body => "User-agent:*\nDisallow: /test")

    robotstxt = Robotstxt.get(URI.parse("http://example.com/index.html"), "Google")

    assert true == robotstxt.allowed?("/index.html")
    assert false == robotstxt.allowed?("/test/index.html")
  end

  def test_existing_http_connection
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :body => "User-agent:*\nDisallow: /test")

    http = Net::HTTP.start("example.com", 80) do |http|
      robotstxt = Robotstxt.get(http, "Google")
      assert true == robotstxt.allowed?("/index.html")
      assert false == robotstxt.allowed?("/test/index.html")
    end
  end

  def test_redirects
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :response => "HTTP/1.1 303 See Other\nLocation: http://www.exemplar.com/robots.txt\n\n")
    FakeWeb.register_uri(:get, "http://www.exemplar.com/robots.txt", :body => "User-agent:*\nDisallow: /private")

    robotstxt = Robotstxt.get("http://example.com/", "Google")

    assert true == robotstxt.allowed?("/index.html")
    assert false == robotstxt.allowed?("/private/index.html")
  end

  def test_encoding
    # "User-agent: *\n Disallow: /encyclop@dia" where @ is the ae ligature (U+00E6)
    FakeWeb.register_uri(:get, "http://example.com/robots.txt", :response => "HTTP/1.1 200 OK\nContent-type: text/plain; charset=utf-16\n\n" +
        "\xff\xfeU\x00s\x00e\x00r\x00-\x00a\x00g\x00e\x00n\x00t\x00:\x00 \x00*\x00\n\x00D\x00i\x00s\x00a\x00l\x00l\x00o\x00w\x00:\x00 \x00/\x00e\x00n\x00c\x00y\x00c\x00l\x00o\x00p\x00\xe6\x00d\x00i\x00a\x00")
    robotstxt = Robotstxt.get("http://example.com/#index", "Google")

    assert true == robotstxt.allowed?("/index.html")
    assert false == robotstxt.allowed?("/encyclop%c3%a6dia/index.html")

  end

end
