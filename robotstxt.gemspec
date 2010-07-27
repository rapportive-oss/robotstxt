# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{robotstxt}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simone Rinzivillo"]
  s.date = %q{2010-02-13}
  s.description = %q{    Robotstxt Parser allows you to the check the accessibility of URLs and get other data.     Full support for the robots.txt RFC, wildcards and Sitemap: rules.
}
  s.email = %q{srinzivillo@gmail.com}
  s.extra_rdoc_files = ["LICENSE.rdoc", "README.rdoc", "lib/robotstxt.rb", "lib/robotstxt/parser.rb"]
  s.files = ["LICENSE.rdoc", "Manifest", "README.rdoc", "Rakefile", "lib/robotstxt.rb", "lib/robotstxt/parser.rb", "test/parser_test.rb", "test/robotstxt_test.rb", "robotstxt.gemspec"]
  s.homepage = %q{http://www.simonerinzivillo.it}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Robotstxt", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{robotstxt}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Robotstxt is an Ruby robots.txt file parser}
  s.test_files = ["test/parser_test.rb", "test/robotstxt_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<echoe>, ["~> 3.1"])
    else
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<echoe>, ["~> 3.1"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<echoe>, ["~> 3.1"])
  end
end
