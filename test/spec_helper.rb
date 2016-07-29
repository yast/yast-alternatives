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

SRC_PATH = File.expand_path("../../src", __FILE__)
DATA_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "data")
ENV["Y2DIR"] = SRC_PATH

require "yast"
require "yast/rspec"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
  end

  # for coverage we need to load all ruby files
  Dir["#{SRC_PATH}/lib/**/**/*.rb"].each { |f| require_relative f }

  # use coveralls for on-line code coverage reporting at Travis CI
  if ENV["TRAVIS"]
    require "coveralls"
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
    ]
  end
end

def alternatives_pip_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "pip", stdout: :capture
  ).and_return(
    "Name: pip\n" \
      "Link: /usr/bin/pip\n" \
      "Status: auto\n" \
      "Best: /usr/bin/pip3.4\n" \
      "Value: /usr/bin/pip3.4\n" \
      "\n" \
      "Alternative: /usr/bin/pip3.4\n" \
      "Priority: 30\n" \
  )
end

def alternatives_pip_with_two_choices_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--get-selections", stdout: :capture
  ).and_return(
    "pip                            auto     /usr/bin/pip3.4\n"
  )
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "pip", stdout: :capture
  ).and_return(
    "Name: pip\n" \
      "Link: /usr/bin/pip\n" \
      "Status: auto\n" \
      "Best: /usr/bin/pip3.4\n" \
      "Value: /usr/bin/pip3.4\n" \
      "\n" \
      "Alternative: /usr/bin/pip2.7\n" \
      "Priority: 20\n" \
      "\n" \
      "Alternative: /usr/bin/pip3.4\n" \
      "Priority: 30\n"
  )
end

def zero_alternatives_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--get-selections", stdout: :capture
  ).and_return(
    ""
  )
end

def alternative_rake_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "rake", stdout: :capture
  ).and_return(
    "Name: rake\n" \
      "Link: /usr/bin/rake\n" \
      "Status: auto\n" \
      "Best: /usr/bin/rake.ruby.ruby2.1\n" \
      "Value: /usr/bin/rake.ruby.ruby2.1\n" \
      "\n" \
      "Alternative: /usr/bin/rake.ruby.ruby2.1\n" \
      "Priority: 2\n"
  )
end

def alternative_rubocop_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "rubocop.ruby2.1", stdout: :capture
  ).and_return(
    "Name: rubocop.ruby2.1\n" \
      "Link: /usr/bin/rubocop.ruby2.1\n" \
      "Status: auto\n" \
      "Best: /usr/bin/rubocop.ruby2.1-0.29.1\n" \
      "Value: /usr/bin/rubocop.ruby2.1-0.29.1\n" \
      "\n" \
      "Alternative: /usr/bin/rubocop.ruby2.1-0.29.1\n" \
      "Priority: 2901\n"
  )
end

def some_alternatives_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--get-selections", stdout: :capture
  ).and_return(
    "pip                            auto     /usr/bin/pip3.4\n" \
    "rake                           auto     /usr/bin/rake.ruby.ruby2.1\n" \
    "rubocop.ruby2.1                auto     /usr/bin/rubocop.ruby2.1-0.29.1\n" \
  )
  alternatives_pip_stub
  alternative_rake_stub
  alternative_rubocop_stub
end

def alternative_without_choices_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--get-selections", stdout: :capture
  ).and_return(
    "pip                            auto     \n"
  )
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "pip", stdout: :capture
  ).and_return(
    "Name: pip\n" \
      "Link: /usr/bin/pip\n" \
      "Status: auto\n" \
      "Value: none\n"
  )
end

def some_alternatives_some_without_choices_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--get-selections", stdout: :capture
  ).and_return(
    "rake                           auto     /usr/bin/rake.ruby.ruby2.1\n" \
    "pip                            auto     \n" \
    "editor                         auto     \n" \
    "rubocop.ruby2.1                auto     /usr/bin/rubocop.ruby2.1-0.29.1\n"
  )
  alternative_rake_stub
  alternative_rubocop_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "pip", stdout: :capture
  ).and_return(
    "Name: pip\n" \
      "Link: /usr/bin/pip\n" \
      "Status: auto\n" \
      "Value: none\n"
  )
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "editor", stdout: :capture
  ).and_return(
    "Name: editor\n" \
      "Link: /usr/bin/editor\n" \
      "Status: auto\n" \
      "Value: none\n"
  )
end

def editor_alternative_automatic_mode
  Y2Alternatives::Alternative.new(
    "editor",
    "auto",
    "/usr/bin/vim",
    [
      Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
      Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
    ]
  )
end

def editor_alternative_manual_mode
  Y2Alternatives::Alternative.new(
    "editor",
    "manual",
    "/usr/bin/nano",
    [
      Y2Alternatives::Alternative::Choice.new("/usr/bin/nano", "20", ""),
      Y2Alternatives::Alternative::Choice.new("/usr/bin/vim", "30", "")
    ]
  )
end

def alternative_with_slaves_stub
  allow(Cheetah).to receive(:run).with(
    "update-alternatives", "--query", "editor", stdout: :capture
  ).and_return(
    "Name: editor\n" \
      "Link: /usr/bin/editor\n" \
      "Slaves:\n" \
      " editor.1.gz /usr/share/man/man1/editor.1.gz\n" \
      " editor.fr.1.gz /usr/share/man/fr/man1/editor.1.gz\n" \
      " editor.it.1.gz /usr/share/man/it/man1/editor.1.gz\n" \
      " editor.pl.1.gz /usr/share/man/pl/man1/editor.1.gz\n" \
      " editor.ru.1.gz /usr/share/man/ru/man1/editor.1.gz\n" \
      "Status: auto\n" \
      "Best: /usr/bin/vim.basic\n" \
      "Value: /usr/bin/vim.basic\n" \
      "\n" \
      "Alternative: /bin/ed\n" \
      "Priority: -100\n" \
      "Slaves:\n" \
      " editor.1.gz /usr/share/man/man1/ed.1.gz\n" \
      "\n" \
      "Alternative: /usr/bin/vim.basic\n" \
      "Priority: 50\n" \
      "Slaves:\n" \
      " editor.1.gz /usr/share/man/man1/vim.1.gz\n" \
      " editor.fr.1.gz /usr/share/man/fr/man1/vim.1.gz\n" \
      " editor.it.1.gz /usr/share/man/it/man1/vim.1.gz\n" \
      " editor.pl.1.gz /usr/share/man/pl/man1/vim.1.gz\n" \
      " editor.ru.1.gz /usr/share/man/ru/man1/vim.1.gz\n" \
  )
end

def alternative_with_slaves_expected_choices
  [
    Y2Alternatives::Alternative::Choice.new("/bin/ed",
      "-100",
      "editor.1.gz /usr/share/man/man1/ed.1.gz\n"),
    Y2Alternatives::Alternative::Choice.new(
      "/usr/bin/vim.basic",
      "50",
      "editor.1.gz /usr/share/man/man1/vim.1.gz\n" \
      "editor.fr.1.gz /usr/share/man/fr/man1/vim.1.gz\n" \
      "editor.it.1.gz /usr/share/man/it/man1/vim.1.gz\n" \
      "editor.pl.1.gz /usr/share/man/pl/man1/vim.1.gz\n" \
      "editor.ru.1.gz /usr/share/man/ru/man1/vim.1.gz\n"
    )
  ]
end

def cancel_event
  {
    "EventReason"      => "Activated",
    "EventSerialNo"    => 0,
    "EventType"        => "WidgetEvent",
    "ID"               => :cancel,
    "WidgetClass"      => :PushButton,
    "WidgetDebugLabel" => "Cancel",
    "WidgetID"         => :cancel
  }
end

def table_selection_changed
  {
    "EventReason"   => "SelectionChanged",
    "EventSerialNo" => 0,
    "EventType"     => "WidgetEvent",
    "ID"            => :choices_table,
    "WidgetClass"   => :Table,
    "WidgetID"      => :choices_table
  }
end

def double_click_on_table
  {
    "EventReason"   => "Activated",
    "EventSerialNo" => 0,
    "EventType"     => "WidgetEvent",
    "ID"            => :choices_table,
    "WidgetClass"   => :Table,
    "WidgetID"      => :choices_table
  }
end

def automatic_mode_event
  {
    "EventReason"      => "Activated",
    "EventSerialNo"    => 0,
    "EventType"        => "WidgetEvent",
    "ID"               => :auto,
    "WidgetClass"      => :PushButton,
    "WidgetDebugLabel" => "Set automatic mode",
    "WidgetID"         => :auto
  }
end

def set_choice_event
  {
    "EventReason"      => "Activated",
    "EventSerialNo"    => 0,
    "EventType"        => "WidgetEvent",
    "ID"               => :set,
    "WidgetClass"      => :PushButton,
    "WidgetDebugLabel" => "Set choice",
    "WidgetID"         => :set
  }
end
