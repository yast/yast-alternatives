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
require "y2_alternatives/dialog/edit_alternative"
require "y2_alternatives/alternative"

describe Y2Alternatives::Dialog::EditAlternative do
  def mock_ui_events(*events)
    allow(Yast::UI).to receive(:WaitForEvent).and_return(*events)
  end

  def mock_selected_choice(*values)
    allow(Yast::UI).to receive(:QueryWidget).with(:choices_table, :CurrentItem)
      .and_return(*values)
  end

  before do
    allow(Yast::UI).to receive(:OpenDialog).and_return(true)
    allow(Yast::UI).to receive(:CloseDialog).and_return(true)
    mock_selected_choice(alternative.value)
  end

  let(:alternative) do
    Y2Alternatives::Alternative.new(
      "editor",
      "manual",
      "/usr/bin/nano",
      [
        Y2Alternatives::Alternative::Choice.new("/usr/bin/emacs", "15", "emacs slaves\n line2"),
        Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", "nano slaves\n line2"),
        Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "vim slaves\n line2")
      ]
    )
  end

  subject(:dialog) { Y2Alternatives::Dialog::EditAlternative.new(alternative) }

  describe "#run" do
    it "selects the Alternative's current choice and show his slaves" do
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(:choices_table, :CurrentItem, alternative.value)
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(:slaves, :Value, "<pre>nano slaves\n line2</pre>")
      mock_ui_events(cancel_event)
      dialog.run
    end
  end

  describe "#auto_handler" do
    before do
      mock_ui_events(automatic_mode_event)
    end

    it "calls Alternative#automatic_mode!" do
      expect(alternative).to receive(:automatic_mode!)
      dialog.run
    end

    it "closes the dialog with true" do
      expect(dialog.run).to eq true
    end
  end

  describe "#set_handler" do
    before do
      mock_ui_events(set_choice_event)
    end

    it "calls Alternative#choose! with the path of the selected choice in the table" do
      # Mock two values, first is used when open the dialog,
      # and the second is used when triggering set_handler.
      mock_selected_choice(alternative.value, "/usr/bin/vim")
      expect(alternative).to receive(:choose!).with("/usr/bin/vim")
      dialog.run
    end

    it "closes the dialog with true" do
      expect(dialog.run).to eq true
    end
  end

  describe "#cancel_handler" do
    before do
      mock_ui_events(cancel_event)
    end

    it "doesn't modify the alternative" do
      expect(alternative).to_not receive(:choose!)
      expect(alternative).to_not receive(:automatic_mode!)
      dialog.run
    end

    it "closes the dialog with nil" do
      expect(dialog.run).to eq nil
    end
  end

  describe "#choices_table_handler" do
    context "when change the selected item" do
      before do
        mock_ui_events(table_selection_changed, cancel_event)
      end

      it "updates slaves list when a choice is selected" do
        # Mock two values, first is used when open the dialog,
        # and the second is used when triggering choices_table_handler.
        mock_selected_choice(alternative.value, "/usr/bin/vim")
        allow(Yast::UI).to receive(:ChangeWidget)
          .with(:choices_table, :CurrentItem, alternative.value)
        allow(Yast::UI).to receive(:ChangeWidget)
          .with(:slaves, :Value, "<pre>nano slaves\n line2</pre>")

        expect(Yast::UI).to receive(:ChangeWidget)
          .with(:slaves, :Value, "<pre>vim slaves\n line2</pre>")
        dialog.run
      end
    end

    context "when double click on an item" do
      before do
        mock_ui_events(double_click_on_table, cancel_event)
      end

      it "calls #set_handler" do
        expect(dialog).to receive(:set_handler).and_call_original
        dialog.run
      end
    end
  end
end
