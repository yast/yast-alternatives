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
require "y2_alternatives/dialog/alternative"
require "y2_alternatives/alternative"

Yast.import "UI"
Yast.import "Popup"

module Y2Alternatives
  module Dialog
    # Dialog where all alternatives groups in the system are listed.
    class ListAlternatives < UI::Dialog
      def initialize
        @alternatives_list = Y2Alternatives::Alternative.all.reject(&:empty?)
        @multi_choice_only = true
        @search = ""
        @changes = false
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
        index = Yast::UI.QueryWidget(:alternatives_table, :CurrentItem)
        @changes = true if Alternative.new(@alternatives_list[index]).run
        update_table(index)
      end

      def update_table(index)
        Yast::UI.ChangeWidget(
          Id(:alternatives_table),
          Cell(index, 1),
          @alternatives_list[index].value
        )
        Yast::UI.ChangeWidget(
          Id(:alternatives_table),
          Cell(index, 2),
          @alternatives_list[index].status
        )
      end

      def accept_handler
        @alternatives_list.each(&:save)
        finish_dialog
      end

      def cancel_handler
        if @changes
          confirmation = Yast::Popup.ContinueCancel(
            _("All the changes will be lost if you leave with Cancel.\nDo you really want to quit?")
          )
          finish_dialog(:cancel) if confirmation
        else
          finish_dialog(:cancel)
        end
      end

      alias_method :alternatives_table_handler, :edit_alternative_handler

      def multi_choice_only_handler
        @multi_choice_only = Yast::UI.QueryWidget(:multi_choice_only, :Value)
        redraw_table
      end

      def search_handler
        @search = Yast::UI.QueryWidget(:search, :Value)
        redraw_table
      end

      def redraw_table
        Yast::UI.ChangeWidget(:alternatives_table, :Items, map_alternatives_items)
      end

      def create_table
        Table(
          Id(:alternatives_table),
          Opt(:notify),
          Header(_("Name"), _("Current choice"), _("Status")),
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
        list = @alternatives_list.each_with_index
        list = list.select { |a, _i| a.choices.length > 1 } if @multi_choice_only
        list = list.select { |a, _i| a.name.include?(@search) } unless @search.empty?
        list
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
end
