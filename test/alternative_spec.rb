require_relative "spec_helper.rb"

describe UpdateAlternatives::Alternative do

  describe ".all" do
    subject { UpdateAlternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(subject.class).to eq Array
      subject.all? { |e| expect(e).to be_a(UpdateAlternatives::Alternative) }
    end

    context "alternative with one choice" do
      it "produce an Alternative object with single choice in choices" do
        alternatives_pip_stub
        choice = UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        expected_choices = { "/usr/bin/pip3.4" => choice }

        expect(subject.first).to have_attributes(
          name: "pip", status: "auto", value: "/usr/bin/pip3.4", choices: expected_choices
        )
      end
    end
    context "alternative with two choices" do
      it "produce an Alternative object with two choices in choices" do
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
