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

    MIN_WIDTH = 60
    MIN_HEIGHT = 20

    def initialize
      @mock_slaves = {
        :ed => %!<pre>editor.1.gz /usr/share/man/man1/ed.1.gz</pre>!,
        :vim => %!<pre>editor.1.gz /usr/share/man/man1/vim.1.
editor.fr.1.gz /usr/share/man/fr/man1/vim.1.gz
editor.it.1.gz /usr/share/man/it/man1/vim.1.gz
editor.pl.1.gz /usr/share/man/pl/man1/vim.1.gz
editor.ru.1.gz /usr/share/man/ru/man1/vim.1.gz
</pre>!
      }
    end

    def dialog_content
      MinSize(
        MIN_WIDTH,
        MIN_HEIGHT,
        VBox(
          create_alternatives_table,
          RichText(Id(:slaves), _("Please select an alternative to view his slaves.")),
          footer
        )
      )
    end

    def set_handler
      finish_dialog()
    end

    def auto_handler
      log.info("You have use the \"Set automatic mode\" button")
      finish_dialog()
    end

    def alternatives_handler
      selected_alternative = Yast::UI.QueryWidget(Id(:alternatives), :CurrentItem)
      Yast::UI.ChangeWidget(Id(:slaves), :Value, @mock_slaves[selected_alternative])
    end

    def create_alternatives_table
      Table(
        Id(:alternatives),
        Opt(:notify, :immediate),
        Header(_("Alternative"), _("Priority")),
        [
          Item(Id(:vim), "/usr/bin/vim.basic", "50"),
          Item(Id(:ed), "/bin/ed", "-100")
        ]
      )
    end

    def footer
      HBox(
        PushButton(Id(:set), _("Set alternative")),
        PushButton(Id(:auto), _("Set automatic mode")),
        PushButton(Id(:cancel), _("Cancel"))
      )
    end
  end
end
