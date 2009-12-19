$:.unshift(File.dirname(__FILE__) + "/lib")

require 'rubygems'
require 'rake'
require 'echoe'
require 'robotstxt'


# Common package properties
PKG_NAME    = 'robotstxt'
PKG_VERSION = Robotstxt::VERSION
RUBYFORGE_PROJECT = 'robotstxt'

if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end
 
 
Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Simone Rinzivillo"
  p.email         = "srinzivillo@gmail.com"
  p.summary       = "Robotstxt is an Ruby robots.txt file parser"
  p.url           = "http://www.simonerinzivillo.it"
  p.project       = RUBYFORGE_PROJECT
  p.description   = <<-EOD
    Robotstxt Parser allows you to the check the accessibility of URLs and get other data. \
    Full support for the robots.txt RFC, wildcards and Sitemap: rules.
  EOD

  p.need_zip      = true

  p.development_dependencies += ["rake  ~>0.8",
                                 "echoe ~>3.1"]

  p.rcov_options  = ["-Itest -x mocha,rcov,Rakefile"]
end


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r robotstxt.rb"
end

begin
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["Robotstxt", "lib"],
                       ["Tests", "test"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end

Dir["tasks/**/*.rake"].each do |file|
  load(file)
end
