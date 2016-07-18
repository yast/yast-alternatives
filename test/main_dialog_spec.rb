require_relative "spec_helper.rb"
require "update-alternatives/UI/main_dialog"

describe UpdateAlternatives::MainDialog do
  def mock_ui_events(*events)
    allow(Yast::UI).to receive(:UserInput).and_return(*events)
  end

  subject(:dialog) { UpdateAlternatives::MainDialog.new }

  let(:loaded_alternatives_list) do
    [
      editor_alternative_automatic_mode,
      UpdateAlternatives::EmptyAlternative.new("rake"),
      UpdateAlternatives::Alternative.new(
        "pip",
        "auto",
        "/usr/bin/pip3.4",
        [
          UpdateAlternatives::Alternative::Choice.new("/usr/bin/pip3.4", "30", "")
        ]
      ),
      UpdateAlternatives::EmptyAlternative.new("rubocop"),
      UpdateAlternatives::Alternative.new(
        "test",
        "manual",
        "/usr/bin/test2",
        [
          UpdateAlternatives::Alternative::Choice.new("/usr/bin/test1", "200", ""),
          UpdateAlternatives::Alternative::Choice.new("/usr/bin/test2", "3", "")
        ]
      )
    ]
  end

  before do
    allow(Yast::UI).to receive(:OpenDialog).and_return(true)
    allow(Yast::UI).to receive(:CloseDialog).and_return(true)
    allow(UpdateAlternatives::Alternative).to receive(:all)
      .and_return(loaded_alternatives_list)
  end

  def expect_update_table_with(expected_items)
    expect(Yast::UI).to receive(:ChangeWidget) do |widgetId, option, itemsList|
      expect(widgetId).to eq(:alternatives_table)
      expect(option).to eq(:Items)
      expect(itemsList.map(&:params)).to eq(expected_items)
    end
  end

  describe "#run" do
    it "ignores EmptyAlternative ojects" do
      dialog.instance_variable_get(:@alternatives_list).each do |alternative|
        expect(alternative).not_to be_an(UpdateAlternatives::EmptyAlternative)
      end
    end
  end

  describe "#multi_choice_only_handler" do
    before do
      mock_ui_events(:multi_choice_only, :cancel)
    end

    context "if multi_choice_only filter is enabled" do
      before do
        allow(Yast::UI).to receive(:QueryWidget).with(:multi_choice_only, :Value).and_return(true)
      end

      it "update the table of alternative excluding the alternatives with only one choice" do
        expect_update_table_with(
          [
            [Id(0), "editor", "/usr/bin/vim", "auto"],
            [Id(2), "test", "/usr/bin/test2", "manual"]
          ]
        )
        dialog.run
      end
    end

    context "if multi_choice_only filter is disabled" do
      before do
        allow(Yast::UI).to receive(:QueryWidget).with(:multi_choice_only, :Value).and_return(false)
      end

      it "update the table of alternative including the alternative with only one choice" do
        expect_update_table_with(
          [
            [Id(0), "editor", "/usr/bin/vim", "auto"],
            [Id(1), "pip", "/usr/bin/pip3.4", "auto"],
            [Id(2), "test", "/usr/bin/test2", "manual"]
          ]
        )
        dialog.run
      end
    end
  end

  describe "#edit_alternative_handler" do
    before do
      mock_ui_events(:edit_alternative, :cancel)
      allow(Yast::UI).to receive(:QueryWidget).with(:alternatives_table, :CurrentItem).and_return(2)
    end

    let(:alternative_dialog) { double("AlternativeDialog") }

    it "opens an AlternativeDialog with the selected alternative" do
      expect(UpdateAlternatives::AlternativeDialog).to receive(:new)
        .with(loaded_alternatives_list[4])
        .and_return(alternative_dialog)
      expect(alternative_dialog).to receive(:run)

      dialog.run
    end

    it "updates the modified alternative on the table" do
      allow(UpdateAlternatives::AlternativeDialog).to receive(:new)
        .and_return(alternative_dialog)
      allow(alternative_dialog).to receive(:run)

      # Need to change two cells, the first to update-alternatives the "Current choice"
      # and the second to update the "Status"
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(Id(:alternatives_table), Cell(2, 1), "/usr/bin/test2")
      expect(Yast::UI).to receive(:ChangeWidget)
        .with(Id(:alternatives_table), Cell(2, 2), "manual")

      dialog.run
    end
  end

  describe "#search_handler" do
    before do
      # First we send :multi_choice_only event to disable the filter.
      mock_ui_events(:multi_choice_only, :search, :cancel)
      allow(Yast::UI).to receive(:QueryWidget).with(:multi_choice_only, :Value).and_return(false)
      # Expect fill the alternatives table when opening the dialog.
      expect_update_table_with(
        [
          [Id(0), "editor", "/usr/bin/vim", "auto"],
          [Id(1), "pip", "/usr/bin/pip3.4", "auto"],
          [Id(2), "test", "/usr/bin/test2", "manual"]
        ]
      )
    end

    context "if the input field is empty" do
      it "shows all alternatives" do
        allow(Yast::UI).to receive(:QueryWidget).with(:search, :Value).and_return("")
        expect_update_table_with(
          [
            [Id(0), "editor", "/usr/bin/vim", "auto"],
            [Id(1), "pip", "/usr/bin/pip3.4", "auto"],
            [Id(2), "test", "/usr/bin/test2", "manual"]
          ]
        )
        dialog.run
      end
    end

    context "if the input field has text that match with some alternative's name" do
      it "shows the alternatives who match its name with the text" do
        allow(Yast::UI).to receive(:QueryWidget).with(:search, :Value).and_return("ed")
        expect_update_table_with([[Id(0), "editor", "/usr/bin/vim", "auto"]])
        dialog.run
      end
    end

    context "if the input field has text that does not match with any alternative's name" do
      it "does not show any alternative" do
        allow(Yast::UI).to receive(:QueryWidget).with(:search, :Value).and_return("no match")
        expect_update_table_with([])
        dialog.run
      end
    end
  end

  describe "#accept_handler" do
    before do
      mock_ui_events(:accept)
    end

    it "saves all changes" do
      expect(dialog.instance_variable_get(:@alternatives_list)).to all receive(:save)
      dialog.run
    end

    it "closes the dialog" do
      expect(dialog).to receive(:finish_dialog).and_call_original
      dialog.run
    end
  end

  describe "#cancel_handler" do
    context "if there are any change" do
      before do
        mock_ui_events(:edit_alternative, :cancel)
        allow(Yast::UI).to receive(:QueryWidget)
          .with(:alternatives_table, :CurrentItem)
          .and_return(0)
        allow(UpdateAlternatives::AlternativeDialog).to receive(:new)
          .and_return(double("AlternativeDialog", run: true))
      end

      it "shows a confirmation dialog" do
        expect(Yast::Popup).to receive(:ContinueCancel)
          .with(
            "All the changes will be lost if you leave with Cancel.\nDo you really want to quit?"
          ).and_return(true)
        dialog.run
      end

      context "if user confirm to leave" do
        before do
          allow(Yast::Popup).to receive(:ContinueCancel)
            .and_return(true)
        end

        it "closes the dialog with :cancel symbol" do
          expect(dialog).to receive(:finish_dialog).with(:cancel).and_call_original
          dialog.run
        end

        it "doesn't save any change" do
          expect_any_instance_of(UpdateAlternatives::Alternative).to_not receive(:save)
          dialog.run
        end
      end

      context "if user doesn't confirm to leave" do
        before do
          # First cancel, and then accept to close the dialog.
          mock_ui_events(:edit_alternative, :cancel, :accept)
          allow(Yast::Popup).to receive(:ContinueCancel)
            .and_return(false)
        end

        it "doesn't close the dialog" do
          expect(dialog).not_to receive(:finish_dialog).with(:cancel)
          allow(dialog).to receive(:finish_dialog).and_call_original
          dialog.run
        end
      end
    end

    context "if there aren't any change" do
      before do
        mock_ui_events(:cancel)
      end

      it "doesn't show confirmation dialog" do
        expect(Yast::Popup).not_to receive(:ContinueCancel)
        dialog.run
      end

      it "closes the dialog with :cancel symbol" do
        expect(dialog.run).to eq :cancel
      end
    end
  end

  describe "#help_handler" do
    before do
      mock_ui_events(:help, :cancel)
    end

    it "launch a help popup" do
      expect(Yast::Popup).to receive(:LongText).with(
        "Help",
        RichText(
          "<p>The status of an alternative, can be automatic or manual. In <b>automatic mode</b> "\
          "the system set the choice with higher priority. The <b>manual mode</b> it is set " \
          "when the user selects a choice manually. " \
          "When change the current choice also his <b>slaves</b> are modified in the system.</p>" \
          "<p>To change the current choice of an alternative, select the alternative, click the " \
          "edit button then select the desired choice in the table and click on the set choice " \
          "button. If you want to set the alternative in automatic mode just click the set " \
          "automatic mode button in the edit dialog.</p>"
        ),
        60,
        20
      )
      dialog.run
    end
  end
end
