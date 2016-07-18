# Copyright (c) 2016 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require_relative "../spec_helper.rb"
require "update-alternatives/model/alternative"
require "update-alternatives/control/set_choice_command"
require "update-alternatives/control/automatic_mode_command"

describe Y2Alternatives::Control::SetChoiceCommand do
  subject(:alternative) do
    Y2Alternatives::Alternative.new(
      "editor",
      "manual",
      "/usr/bin/nano",
      [
        Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
        Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
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
      Y2Alternatives::Control::SetChoiceCommand.execute(alternative)
    end
  end
end

describe Y2Alternatives::Control::AutomaticModeCommand do
  subject(:alternative) do
    Y2Alternatives::Alternative.new(
      "editor",
      "auto",
      "/usr/bin/vim",
      [
        Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
        Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
      ]
    )
  end

  describe "#execute" do
    it "set the automatic mode for given alternative on the system" do
      expect(Cheetah).to receive(:run).with("update-alternatives", "--auto", "editor")
      Y2Alternatives::Control::AutomaticModeCommand.execute(alternative)
    end
  end
end
