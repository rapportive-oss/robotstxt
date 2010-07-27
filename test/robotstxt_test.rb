$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'robotstxt'

class TestRobotstxt < Test::Unit::TestCase
  
  
  def test_allowed
    assert true == Robotstxt.allowed?('http://www.simonerinzivillo.it/', 'rubytest')
    assert false == Robotstxt.allowed?('http://www.simonerinzivillo.it/no-dir/', 'rubytest')
  end
  
  def test_sitemaps
    assert Robotstxt.sitemaps('http://www.simonerinzivillo.it/', 'rubytest').length > 0
  end
  
  
end
