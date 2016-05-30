SRC_PATH = File.expand_path("../../src", __FILE__)
DATA_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "data")
ENV["Y2DIR"] = SRC_PATH

require "yast"
require "yast/rspec"

def alternatives_names_stub
  allow(Cheetah).to receive(:run).and_return(
    "pilconvert                     auto     /usr/bin/pilconvert-2.7\n" \
    "pip                            auto     /usr/bin/pip3.4\n" \
    "rake                           auto     /usr/bin/rake.ruby.ruby2.1\n" \
    "rake.ruby2.1                   auto     /usr/bin/rake.ruby.ruby2.1\n" \
    "rdoc                           auto     /usr/bin/rdoc.ruby.ruby2.1\n" \
    "rdoc.ruby2.1                   auto     /usr/bin/rdoc.ruby.ruby2.1\n" \
    "ri                             auto     /usr/bin/ri.ruby.ruby2.1\n" \
    "ri.ruby2.1                     auto     /usr/bin/ri.ruby.ruby2.1\n"
  )
end

def alternatives_pip_stub
  allow(Cheetah).to receive(:run).and_return(
    "pip                            auto     /usr/bin/pip3.4\n",
    "Name: pip\n" \
	    "Link: /usr/bin/pip\n" \
	    "Status: auto\n" \
	    "Best: /usr/bin/pip3.4\n" \
	    "Value: /usr/bin/pip3.4\n" \
	    "\n" \
	    "Alternative: /usr/bin/pip3.4\n" \
	    "Priority: 30\n" \
  )
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
