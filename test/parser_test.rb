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
	
end