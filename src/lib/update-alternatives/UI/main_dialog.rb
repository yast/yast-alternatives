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
require "update-alternatives/UI/alternatives_dialog"
require "update-alternatives/model/alternative"

Yast.import "UI"

module UpdateAlternatives
  # Dialog where all alternatives groups in the system are listed.
  class MainDialog < UI::Dialog
    def dialog_options
      Opt(:decorated, :defaultsize)
    end

    def dialog_content
      VBox(
        create_table,
        footer
      )
    end

    def show_handler
      AlternativesDialog.new.run
    end

    def alternatives_table_handler
      AlternativesDialog.new.run
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
      UpdateAlternatives::Alternative.all.map do |alternative|
        Item(Id(:test), alternative.name, alternative.value, _(alternative.status))
      end
    end

    def footer
      HBox(
        PushButton(Id(:show), _("Show alternatives")),
        PushButton(Id(:cancel), Yast::Label.CancelButton)
      )
    end
  end
end
