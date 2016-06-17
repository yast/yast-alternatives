require_relative "spec_helper.rb"
require "update-alternatives/model/alternative"
require "update-alternatives/control/set_choice_command"
require "update-alternatives/control/automatic_mode_command"

describe UpdateAlternatives::SetChoiceCommand do
  subject(:alternative) do
    UpdateAlternatives::Alternative.new(
      "editor",
      "manual",
      "/usr/bin/nano",
      [
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
      ]
    )
  end

  describe "#execute" do
    it "set the actual choice for given alternative on the system" do
      expect(Cheetah).to receive(:run).with("update-alternatives",
        "--set",
        "editor",
        "/usr/bin/nano"
      )
      UpdateAlternatives::SetChoiceCommand.execute(alternative)
    end
  end
end

describe UpdateAlternatives::AutomaticModeCommand do
  subject(:alternative) do
    UpdateAlternatives::Alternative.new(
      "editor",
      "auto",
      "/usr/bin/vim",
      [
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
      ]
    )
  end

  describe "#execute" do
    it "set the automatic mode for given alternative on the system" do
      expect(Cheetah).to receive(:run).with("update-alternatives", "--auto", "editor")
      UpdateAlternatives::AutomaticModeCommand.execute(alternative)
    end
  end
end
