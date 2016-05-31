require_relative "spec_helper.rb"

describe "UpdateAlternatives::Alternative" do

  context "when we get all alternatives names" do
    it "should return an array with all alternatives names" do

      alternatives_names_stub
      expected_names = %w(pilconvert pip rake rake.ruby2.1 rdoc rdoc.ruby2.1 ri ri.ruby2.1)

      alternatives_name_list = UpdateAlternatives::Alternative.all_names

      expect(alternatives_name_list).to eq expected_names
    end
  end

  describe ".all" do
    subject { UpdateAlternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(subject.class).to eq Array
      expect(subject.all? { |e| e.is_a?(UpdateAlternatives::Alternative) }).to eq true
    end

    context "alternative with one choice" do
      it "is loaded correctly" do
        alternatives_pip_stub
        choice = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        expected_choices = { "/usr/bin/pip3.4" => choice }

        expect(subject.first).to have_attributes(
          name: "pip", status: "auto", value: "/usr/bin/pip3.4", choices: expected_choices
        )
      end
    end
    context "alternative with two choices" do
      it "is loaded correctly" do
        alternatives_pip_with_two_choices_stub

        choice_one = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        choice_two = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip2.7", "20", "")
        expected_choices = { "/usr/bin/pip3.4" => choice_one, "/usr/bin/pip2.7" => choice_two }

        expect(subject.first).to have_attributes(
          name: "pip", status: "auto", value: "/usr/bin/pip3.4", choices: expected_choices
        )
      end
    end
  end
end
