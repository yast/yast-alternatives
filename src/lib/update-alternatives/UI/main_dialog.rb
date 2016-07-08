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

require "yast"
require "ui/dialog"
require "update-alternatives/UI/alternative_dialog"
require "update-alternatives/model/alternative"

Yast.import "UI"

module UpdateAlternatives
  # Dialog where all alternatives groups in the system are listed.
  class MainDialog < UI::Dialog
    def initialize
      @alternatives_list = UpdateAlternatives::Alternative.all.reject(&:empty?)
      @multi_choice_only = true
      @search = ""
    end

    def dialog_options
      Opt(:decorated, :defaultsize)
    end

    def dialog_content
      VBox(
        filters,
        create_table,
        footer
      )
    end

    def edit_alternative_handler
      index = Yast::UI.QueryWidget(Id(:alternatives_table), :CurrentItem)
      AlternativeDialog.new(@alternatives_list[index]).run
      redraw_table
    end

    def accept_handler
      @alternatives_list.each(&:save)
      finish_dialog
    end

    alias_method :alternatives_table_handler, :edit_alternative_handler

    def multi_choice_only_handler
      @multi_choice_only = Yast::UI.QueryWidget(:multi_choice_only, :Value)
      redraw_table
    end

    def search_handler
      @search = Yast::UI.QueryWidget(Id(:search), :Value)
      redraw_table
    end

    def redraw_table
      Yast::UI.ChangeWidget(:alternatives_table, :Items, map_alternatives_items)
    end

    def create_table
      Table(
        Id(:alternatives_table),
        Opt(:notify),
        Header(_("Name"), _("Actual alternative"), _("Status")),
        map_alternatives_items
      )
    end

    def map_alternatives_items
      filtered_alternatives.map do |alternative, index|
        Item(
          Id(index),
          alternative.name,
          alternative.value,
          _(alternative.status)
        )
      end
    end

    def filtered_alternatives
      alternatives = @alternatives_list.each_with_index
      alternatives = alternatives.select { |a, _i| a.choices.length > 1 } if @multi_choice_only
      alternatives = alternatives.select { |a, _i| a.name.include?(@search) } unless @search.empty?
      alternatives
    end

    def filters
      VBox(
        InputField(Id(:search), Opt(:notify), _("Search by name"), @search),
        CheckBox(
          Id(:multi_choice_only),
          Opt(:notify),
          _("Show only alternatives with more than one choice"),
          @multi_choice_only
        )
      )
    end

    def footer
      HBox(
        PushButton(Id(:edit_alternative), Yast::Label.EditButton),
        PushButton(Id(:cancel), Yast::Label.CancelButton),
        PushButton(Id(:accept), Yast::Label.AcceptButton)
      )
    end
  end
end
