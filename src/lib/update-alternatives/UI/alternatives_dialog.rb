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

Yast.import "UI"

module UpdateAlternatives

  class AlternativesDialog < UI::Dialog

    def dialog_content
      VBox(
        create_alternatives_table,
        HBox(
          PushButton(Id(:cancel), _("Cancel"))
        )
      )
    end

    def create_alternatives_table
      Table(
        Id(:alternatives_table),
        Header(_("Alternative"), _("Priority")),
        [
          Item(Id(:java18), "/usr/lib64/jvm/jre-1.8.0-openjdk/bin/java", "1805"),
          Item(Id(:java17), "/usr/lib64/jvm/jre-1.7.0-openjdk/bin/java", "1705"),
        ]
      )
    end
  end
end
