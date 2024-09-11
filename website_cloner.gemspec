Gem::Specification.new do |s|
  s.name        = "website_cloner"
  s.version     = "0.0.2"
  s.summary     = "Create local copies of websites, including all assets and linked pages."
  s.description = "Website Cloner is a Ruby gem that allows you to create local copies of websites, including all assets and linked pages. It's designed to be easy to use while providing powerful features for customization."
  s.authors     = ["Bhavyansh Yadav"]
  s.email       = "bhavyansh001@gmail.com"
  s.files       = Dir["lib/**/*", "bin/*"]
  s.homepage    = "https://rubygems.org/gems/website_cloner"
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.3.0"
  s.metadata = {
    "source_code_uri" => "https://github.com/bhavyansh001/website_cloner",
    "issue_tracker_uri" => "https://github.com/bhavyansh001/website_cloner/issues"
  }

  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "nokogiri", "~> 1.15"
  s.add_dependency "httparty", "~> 0.21"
  s.add_dependency "openssl", "~> 3.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
end
