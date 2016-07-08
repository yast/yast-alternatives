require_relative "spec_helper.rb"
require "update-alternatives/UI/main_dialog"

describe UpdateAlternatives::MainDialog do
  def mock_ui_events(*events)
    allow(Yast::UI).to receive(:UserInput).and_return(*events)
  end

  subject(:dialog) { UpdateAlternatives::MainDialog.new }

  before do
    allow(Yast::UI).to receive(:OpenDialog).and_return(true)
    allow(Yast::UI).to receive(:CloseDialog).and_return(true)
    allow(UpdateAlternatives::Alternative).to receive(:all)
      .and_return(main_dialog_alternatives_list)
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
      it "update the table of alternative excluding the alternatives with only one choice" do
        allow(Yast::UI).to receive(:QueryWidget).with(:multi_choice_only, :Value).and_return(true)
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
      it "update the table of alternative including the alternative with only one choice" do
        allow(Yast::UI).to receive(:QueryWidget).with(:multi_choice_only, :Value).and_return(false)
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

    it "opens an AlternativeDialog with the selected alternative" do
      selected_alternative = dialog.instance_variable_get(:@alternatives_list)[2]
      alternative_dialog = UpdateAlternatives::AlternativeDialog.new(selected_alternative)

      expect(UpdateAlternatives::AlternativeDialog).to receive(:new)
        .with(selected_alternative)
        .and_return(alternative_dialog)
      expect(alternative_dialog).to receive(:run)

      dialog.run
    end

    it "updates the alternatives table" do
      alternative_dialog = UpdateAlternatives::AlternativeDialog.new(nil)
      allow(UpdateAlternatives::AlternativeDialog).to receive(:new)
        .and_return(alternative_dialog)
      allow(alternative_dialog).to receive(:run)

      expect(Yast::UI).to receive(:ChangeWidget).with(:alternatives_table, :Items, kind_of(Array))

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
end
