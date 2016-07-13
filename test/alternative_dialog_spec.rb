require_relative "spec_helper.rb"
require "update-alternatives/UI/alternative_dialog"
require "update-alternatives/model/alternative"

describe UpdateAlternatives::AlternativeDialog do
  def mock_ui_events(*events)
    allow(Yast::UI).to receive(:UserInput).and_return(*events)
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
    UpdateAlternatives::Alternative.new(
      "editor",
      "manual",
      "/usr/bin/nano",
      [
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/emacs", "15", "emacs slaves\n line2"),
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/nano", "20", "nano slaves\n line2"),
        UpdateAlternatives::Alternative::Choice.new("/usr/bin/vim", "30", "vim slaves\n line2")
      ]
    )
  end

  subject(:dialog) { UpdateAlternatives::AlternativeDialog.new(alternative) }

  describe "#run" do
    it "selects the Alternative's current choice and show his slaves" do
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(:choices_table, :CurrentItem, alternative.value)
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(:slaves, :Value, "<pre>nano slaves\n line2</pre>")
      mock_ui_events(:cancel)
      dialog.run
    end
  end

  describe "#auto_handler" do
    before do
      mock_ui_events(:auto)
    end

    it "calls Alternative#automatic_mode!" do
      expect(alternative).to receive(:automatic_mode!)
      dialog.run
    end

    it "closes the dialog" do
      expect(dialog).to receive(:finish_dialog).and_call_original
      dialog.run
    end
  end

  describe "#set_handler" do
    before do
      mock_ui_events(:set)
    end

    it "calls Alternative#choose! with the path of the selected choice in the table" do
      # Mock two values, first is used when open the dialog,
      # and the second is used when triggering set_handler.
      mock_selected_choice(alternative.value, "/usr/bin/vim")
      expect(alternative).to receive(:choose!).with("/usr/bin/vim")
      dialog.run
    end

    it "closes the dialog" do
      expect(dialog).to receive(:finish_dialog).and_call_original
      dialog.run
    end
  end

  describe "#cancel_handler" do
    before do
      mock_ui_events(:cancel)
    end

    it "doesn't modify the alternative" do
      expect(alternative).to_not receive(:choose!)
      expect(alternative).to_not receive(:automatic_mode!)
      dialog.run
    end

    it "closes the dialog" do
      expect(dialog).to receive(:finish_dialog).and_call_original
      dialog.run
    end
  end

  describe "#choices_table_handler" do
    it "updates slaves list when a choice is selected" do
      mock_ui_events(:choices_table, :cancel)
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
end
