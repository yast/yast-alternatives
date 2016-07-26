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

require_relative "../spec_helper.rb"
require "y2_alternatives/dialog/list_alternatives"
require "y2_alternatives/client/start_checking_permissions"

describe Y2Alternatives::Client::StartCheckingPermissions do
  describe "#main" do
    subject(:client) { Y2Alternatives::Client::StartCheckingPermissions.new }

    it "checks if user is root" do
      allow(Y2Alternatives::Dialog::ListAlternatives).to receive(:run)

      expect(Yast::Confirm).to receive(:MustBeRoot).and_return true
      client.main
    end

    context "if a normal user cancel MustBeRoot confirmation" do
      before do
        allow(Yast::Confirm).to receive(:MustBeRoot).and_return false
      end

      it "doesn't create a ListAlternatives dialog" do
        expect(Y2Alternatives::Dialog::ListAlternatives).to_not receive(:run)
        client.main
      end
    end
    context "if a normal user accept MustBeRoot confirmation" do
      before do
        allow(Yast::Confirm).to receive(:MustBeRoot).and_return true
      end

      it "creates a ListAlternatives dialog" do
        expect(Y2Alternatives::Dialog::ListAlternatives).to receive(:run)
        client.main
      end
    end
  end
end
