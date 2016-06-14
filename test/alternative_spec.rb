require_relative "spec_helper.rb"
require "update-alternatives/model/alternative"

describe UpdateAlternatives::Alternative do

  describe ".load" do
    subject(:loaded_alternative) { UpdateAlternatives::Alternative.load("pip") }

    it "returns an Alternative object" do
      alternatives_pip_stub
      expect(loaded_alternative).to be_an UpdateAlternatives::Alternative
    end

    it "initializes the name, status and value" do
      alternatives_pip_stub
      expect(loaded_alternative).to have_attributes(
        name: "pip", status: "auto", value: "/usr/bin/pip3.4"
      )
    end

    it "initializes choices as an array of Choice objects" do
      alternatives_pip_with_two_choices_stub
      expect(loaded_alternative.choices).to be_an Array
      expect(loaded_alternative.choices).to all(be_a(UpdateAlternatives::Alternative::Choice))
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

    context "if there are a choice without slaves" do
      it "initializes his slaves attribute to the empty string" do
        alternatives_pip_with_two_choices_stub
        expect(loaded_alternative.choices).to all(have_attributes(slaves: ""))
      end
    end

    context "if there is an alternative without choices" do
      it "return nil object" do
        alternative_without_choices_stub
        expect(loaded_alternative).to be nil
      end
    end
  end

  describe ".all" do
    subject(:all_alternatives) { UpdateAlternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(all_alternatives).to be_an Array
      expect(all_alternatives).to all(be_an(UpdateAlternatives::Alternative))
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

    context "if there are alternatives without choices" do
      it "return an array of Alternatives objects ignoring the alternatives without choices" do
        some_alternatives_some_without_choices_stub
        expect(all_alternatives.length).to eq 2
        expect(all_alternatives.map(&:name)).to eq ["rake", "rubocop.ruby2.1"]
      end
    end
  end
end
