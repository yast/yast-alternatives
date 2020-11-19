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
require "y2_alternatives/dialog/list_alternatives"

Yast.import "Confirm"

module Y2Alternatives
  module Client
    # Checks if user is root and create a ListAlternatives dialog
    class StartCheckingPermissions
      include Yast::I18n

      def main
        textdomain "alternatives"

        if Yast::WFM.Args.include?("help")
          print_help
          return true
        elsif !Yast::WFM.Args.empty?
          print_help
          return false
        end

        Dialog::ListAlternatives.run if Yast::Confirm.MustBeRoot
      end

    private

      def print_help
        # TRANSLATORS: %s stands for CLI program to use instead of yast module
        msg = format(
          _("This module does not support command line. Use '%s' instead."),
          "update-alternatives"
        )

        cmdline_description = {
          "id"   => "alternatives",
          "help" => msg
        }

        Yast.import "CommandLine"
        Yast::CommandLine.Run(cmdline_description)
      end
    end
  end
end
