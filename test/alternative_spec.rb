require_relative "../spec/spec_helper.rb"

describe "An alternative" do

  context "when we get all alternatives names" do
    it "should return an array with all alternatives names" do

      alternatives_names_stub
      expected_names = %w(pilconvert pip rake rake.ruby2.1 rdoc rdoc.ruby2.1 ri ri.ruby2.1)

      alternatives_name_list = UpdateAlternatives::Alternative.all_names

      expect(alternatives_name_list).to eq expected_names
    end
  end

  context "when we get all alternatives" do
    it "should return a map with a single instanced alternative" do

      alternatives_pip_stub

      alternatives = UpdateAlternatives::Alternative.all
      pip = alternatives.first
      pip_choice = pip.choices["/usr/bin/pip3.4"]

      expect(pip.name).to eq "pip"
      expect(pip.status).to eq "auto"
      expect(pip.value).to eq "/usr/bin/pip3.4"
      expect(pip_choice.path).to eq "/usr/bin/pip3.4"
      expect(pip_choice.priority).to eq "30"
      expect(pip_choice.slaves).to eq ""

    end

    it "should return a map with a single instanced alternative with more than one choice" do

      alternatives_pip_with_two_choices_stub

      alternatives = UpdateAlternatives::Alternative.all
      pip = alternatives.first
      first_pip_choice = pip.choices["/usr/bin/pip2.7"]
      second_pip_choice = pip.choices["/usr/bin/pip3.4"]

      expect(pip.name).to eq "pip"
      expect(pip.status).to eq "auto"
      expect(pip.value).to eq "/usr/bin/pip3.4"
      expect(first_pip_choice.path).to eq "/usr/bin/pip2.7"
      expect(first_pip_choice.priority).to eq "20"
      expect(first_pip_choice.slaves).to eq ""
      expect(second_pip_choice.path).to eq "/usr/bin/pip3.4"
      expect(second_pip_choice.priority).to eq "30"
      expect(second_pip_choice.slaves).to eq ""
    end
  end
end
