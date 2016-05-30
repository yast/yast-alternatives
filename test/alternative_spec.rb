require_relative "../src/lib/update-alternatives/model/alternative"
require "cheetah"

describe "An alternative" do

  before do
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

  context "when we get all alternatives names" do
    it "should return an array with all alternatives names" do

      alternatives_name_list = UpdateAlternatives::Alternative.all_names

      expected_names = %w(pilconvert pip rake rake.ruby2.1 rdoc rdoc.ruby2.1 ri ri.ruby2.1)

      expect(alternatives_name_list).to eq expected_names
    end
  end
end
