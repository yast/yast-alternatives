require_relative "spec_helper.rb"
require "update-alternatives/UI/main_dialog"

describe UpdateAlternatives::MainDialog do
  def mock_ui_events(*events)
    allow(Yast::UI).to receive(:UserInput).and_return(*events)
  end

  subject(:dialog) { UpdateAlternatives::MainDialog }

  before do
    allow(Yast::UI).to receive(:OpenDialog).and_return(true)
    allow(Yast::UI).to receive(:CloseDialog).and_return(true)
  end

  describe "#multi_choice_only_handler" do
    before do
      mock_ui_events(:multi_choice_only, :cancel)
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
end