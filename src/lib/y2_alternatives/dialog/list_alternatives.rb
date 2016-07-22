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
require "y2_alternatives/dialog/edit_alternative"
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

    def help_handler
      Yast::Popup.LongText(
        _("Help"),
        RichText(help_text),
        60,
        20
      )
    end

    def help_text
      _("<p>The alternatives system is used when some equivalent applications are " \
        "installed in the system. For example if several implementations and versions of Java " \
        "are installed, the alternatives system will be used to decide which one to use when " \
        "the command \"java\" is called.</p><p>Every alternative have an " \
        "status, it can be automatic or manual. In <b>automatic mode</b> the system uses " \
        "the choice with higher priority. Note that <b>priority</b> is set by the packages " \
        "creators trying to provide reasonable defaults. The <b>manual mode</b> is set " \
        "when the user selects a choice manually.</p><p>To change the current choice of an " \
        "alternative, select the alternative, click the <b>edit</b> button then select the " \
        "desired choice in the table and click on the <b>set choice</b> button. If you want to " \
        "have the alternative in automatic mode just click the <b>set automatic mode</b> button " \
        "in the edit dialog.</p><p>Furthermore every choice has its own set of <b>slaves</b>, " \
        "these will be applied in the system when the choice is selected.</p><p>For example, " \
        "given an alternative \"editor\" that has two choices." \
        "The first choice \"/bin/ed\" with the slave:</p>" \
        "<pre>  editor.1.gz /usr/share/man/man1/ed.1.gz</pre>"\
        "<p>Another choice \"/usr/bin/vim\" with the following slaves:</p>"\
        "<pre>  editor.1.gz /usr/share/man/man1/vim.1.gz\n" \
        "  editor.fr.1.gz /usr/share/man/fr/man1/vim.1.gz\n" \
        "  editor.it.1.gz /usr/share/man/it/man1/vim.1.gz\n" \
        "  editor.pl.1.gz /usr/share/man/pl/man1/vim.1.gz\n" \
        "  editor.ru.1.gz /usr/share/man/ru/man1/vim.1.gz\n</pre>" \
        "<p>In this case if the second choice is selected all its slaves will be modified, " \
        "or created if they do not exist already. If the \"/bin/ed\" choice is set afterward, " \
        "the slave \"editor.1.gz\" will be modified and the others will be removed.</p>")
    end

      def edit_alternative_handler
        index = Yast::UI.QueryWidget(:alternatives_table, :CurrentItem)
        @changes = true if EditAlternative.new(@alternatives_list[index]).run
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

    def footer
      HBox(
        HSpacing(),
        Left(PushButton(Id(:help), Opt(:key_F1, :help), Yast::Label.HelpButton)),
        PushButton(Id(:edit_alternative), Yast::Label.EditButton),
        PushButton(Id(:cancel), Yast::Label.CancelButton),
        PushButton(Id(:accept), Yast::Label.AcceptButton),
        HSpacing()
      )
    end
  end
end
