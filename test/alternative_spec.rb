require_relative "spec_helper.rb"
require "update-alternatives/model/alternative"

describe UpdateAlternatives::Alternative do

  describe ".all" do
    subject(:all_alternatives) { UpdateAlternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(all_alternatives.class).to eq Array
      expect(all_alternatives).to all(be_a(UpdateAlternatives::Alternative))
    end
    context "with zero alternatives" do
      it "produce an empty array" do
        zero_alternatives_stub
        expect(all_alternatives.length).to eq 0
      end
    end
    context "with one alternative" do
      it "produce an array with one alternative" do
        alternatives_pip_with_two_choices_stub
        expect(all_alternatives.first.name).to eq "pip"
        expect(all_alternatives.length).to eq 1
      end
    end
    context "with three alternatives" do
      it "produce an array with the three alternatives" do
        some_alternatives_stub
        expected_alternatives_names = ["pip", "rake", "rubocop.ruby2.1"]
        alternatives_names = all_alternatives.map { |alternative| alternative.name }

        expect(alternatives_names).to eq expected_alternatives_names
        expect(all_alternatives.length).to eq 3
      end
    end
  end
  describe ".load" do
    subject(:loaded_alternative) { UpdateAlternatives::Alternative.load("pip") }

    context "alternative with one choice" do
      it "produce an Alternative object with single choice in choices" do
        alternatives_pip_stub
        choice = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        expected_choices = [choice]

        expect(loaded_alternative).to have_attributes(
          name: "pip", status: "auto", value: "/usr/bin/pip3.4", choices: expected_choices
        )
      end
    end
    context "alternative with two choices" do
      it "produce an Alternative object with two choices in choices" do
        alternatives_pip_with_two_choices_stub

        choice_one = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip2.7", "20", "")
        choice_two = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        expected_choices = [choice_one, choice_two]

        expect(loaded_alternative).to have_attributes(
          name: "pip", status: "auto", value: "/usr/bin/pip3.4", choices: expected_choices
        )
      end
    end
  end
end
