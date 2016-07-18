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

require_relative "spec_helper.rb"
require "update-alternatives/model/alternative"

describe Y2Alternatives::Alternative do

  describe ".load" do
    subject(:loaded_alternative) { Y2Alternatives::Alternative.load("pip") }
    subject(:alternative_with_slaves) { Y2Alternatives::Alternative.load("editor") }

    it "returns an Alternative object" do
      alternatives_pip_stub
      expect(loaded_alternative).to be_an Y2Alternatives::Alternative
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
      expect(loaded_alternative.choices).to all(be_a(Y2Alternatives::Alternative::Choice))
    end

    it "initializes the path and priority for every choice" do
      alternatives_pip_with_two_choices_stub
      choice_one = Y2Alternatives::Alternative::Choice.new("/usr/bin/pip2.7", "20", "")
      choice_two = Y2Alternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
      expected_choices = [choice_one, choice_two]
      expect(loaded_alternative).to have_attributes(
        choices: expected_choices
      )
    end

    it "initializes slaves for each choice" do
      alternative_with_slaves_stub
      expect(alternative_with_slaves.choices).to eq alternative_with_slaves_expected_choices
    end

    context "if there are a choice without slaves" do
      it "initializes his slaves attribute to the empty string" do
        alternatives_pip_with_two_choices_stub
        expect(loaded_alternative.choices).to all(have_attributes(slaves: ""))
      end
    end

    context "if there is an alternative without choices" do
      it "returns an EmptyAlternative instance" do
        alternative_without_choices_stub
        expect(loaded_alternative).to be_an Y2Alternatives::EmptyAlternative
        expect(loaded_alternative.empty?).to eq true
      end
    end
  end

  describe ".all" do
    subject(:all_alternatives) { Y2Alternatives::Alternative.all }

    it "returns an array of Alternative objects" do
      alternatives_pip_with_two_choices_stub
      expect(all_alternatives).to be_an Array
      expect(all_alternatives).to all(be_an(Y2Alternatives::Alternative))
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
      it "returns an array of Alternatives including the alternatives without choices" do
        some_alternatives_some_without_choices_stub
        expect(all_alternatives).to all(be_an(Y2Alternatives::Alternative))
        expect(all_alternatives.length).to eq 4
        expect(all_alternatives.map(&:name)).to eq ["rake", "pip", "editor", "rubocop.ruby2.1"]
        expect(all_alternatives.map(&:empty?)).to eq [false, true, true, false]
      end
    end
  end

  describe "#choose!" do
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

    it "changes the alternative's actual choice to given parameter" do
      alternative.choose!("/usr/bin/nano")
      expect(alternative.value).to eq "/usr/bin/nano"
    end

    it "changes the status to 'manual'" do
      alternative.choose!("/usr/bin/nano")
      expect(alternative.status).to eq "manual"
    end

    context "if the given choice path doesn't correspond to any of the alternative's choices" do
      it "raises a RuntimeError" do
        expect { alternative.choose!("/usr/bin/not-exists") }.to raise_error(RuntimeError,
          "The alternative doesn't have any choice with path '/usr/bin/not-exists'"
        )
      end
    end
  end

  describe "#automatic_mode!" do
    subject(:alternative) do
      Y2Alternatives::Alternative.new(
        "editor",
        "manual",
        "/usr/bin/nano",
        [
          Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
          Y2Alternatives::Alternative::Choice.new("/usr/bin/emacs", "40", ""),
          Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
        ]
      )
    end

    it "changes the status to 'auto'" do
      alternative.automatic_mode!
      expect(alternative.status).to eq "auto"
    end

    it "changes the actual choice for the choice with highest priority" do
      alternative.automatic_mode!
      expect(alternative.value).to eq "/usr/bin/emacs"
    end
  end

  describe "#save" do
    context "if the alternative is not modificated" do
      subject(:alternative) { editor_alternative_automatic_mode }
      it "do not execute any command" do
        expect(Y2Alternatives::Control::SetChoiceCommand).not_to receive(:execute)
        expect(Y2Alternatives::Control::AutomaticModeCommand).not_to receive(:execute)
        alternative.save
      end
    end

    context "if the alternative's selected choice has changed" do
      subject(:alternative) { editor_alternative_automatic_mode }
      it "execute a SetChoiceCommand" do
        alternative.choose!("/usr/bin/nano")
        expect(Y2Alternatives::Control::SetChoiceCommand).to receive(:execute).with(alternative)
        alternative.save
      end
    end

    context "if the alternative's stastus has changed to automatic mode" do
      subject(:alternative) { editor_alternative_manual_mode }

      it "execute an AutomaticModeCommand" do
        alternative.automatic_mode!
        expect(Y2Alternatives::Control::AutomaticModeCommand).to receive(:execute).with(alternative)
        alternative.save
      end
    end

    context "if the alternative is modified more than once" do
      subject(:alternative) { editor_alternative_automatic_mode }
      it "only execute the last change" do
        alternative.choose!("/usr/bin/nano")
        alternative.automatic_mode!
        expect(Y2Alternatives::Control::SetChoiceCommand).not_to receive(:execute)
        expect(Y2Alternatives::Control::AutomaticModeCommand).to receive(:execute).with(alternative)
        alternative.save
      end
    end
  end
end
