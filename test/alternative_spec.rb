require_relative "spec_helper.rb"
require "update-alternatives/model/alternative"

describe UpdateAlternatives::Alternative do

  describe ".load" do
    subject(:loaded_alternative) { UpdateAlternatives::Alternative.load("pip") }

    it "returns an Alternative object" do
      alternatives_pip_stub
      expect(loaded_alternative.class).to eq UpdateAlternatives::Alternative
    end

    it "initializes the name, status and value" do
      alternatives_pip_stub
      expect(loaded_alternative).to have_attributes(
        name: "pip", status: "auto", value: "/usr/bin/pip3.4"
      )
    end

    it "initializes the path and priority for every choice" do
      alternatives_pip_with_two_choices_stub
      choice_one = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip2.7", "20", "")
      choice_two = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
      expected_choices = [choice_one, choice_two]
      expect(loaded_alternative).to have_attributes(
        choices: expected_choices
      )
    end
  end

  describe ".all" do
    subject(:all_alternatives) { UpdateAlternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(all_alternatives.class).to eq Array
      expect(all_alternatives).to all(be_a(UpdateAlternatives::Alternative))
    end

    context "if there are no alternatives in the system" do
      it "returns an empty array" do
        zero_alternatives_stub
        expect(all_alternatives.length).to eq 0
      end
    end

    context "if there are alternatives in the system" do
      it "returns an array with one Alternative object per known alternative" do
        some_alternatives_stub
        expect(all_alternatives.map(&:name)).to eq ["pip", "rake", "rubocop.ruby2.1"]
        expect(all_alternatives.length).to eq 3
      end
    end
  end
end
