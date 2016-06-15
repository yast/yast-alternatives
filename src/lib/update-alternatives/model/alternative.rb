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

require "cheetah"

module UpdateAlternatives
  # Represents an alternative
  class Alternative
    # @return [String] name of the alternative.
    attr_reader :name
    # @return [String] Status of the alternative, it can be auto or manual.
    attr_reader :status
    # @return [String] Path of the actual choice.
    attr_reader :value
    # @return [Array<Choice>] Contains all Alternative's Choices.
    attr_reader :choices
    # Represents a Choice of an alternative.
    Choice = Struct.new(:path, :priority, :slaves)

    # Creates a new Alternative with the given parameters.
    def initialize(name, status, value, choices)
      @name = name
      @status = status
      @value = value
      @choices = choices
    end

    # @return [Array<String>] an array with the names of the alternatives.
    def self.all_names
      raw_data = Cheetah.run("update-alternatives", "--get-selections", stdout: :capture).lines
      raw_data.map { |string| string.split.first }
    end

    # @return [Array<Alternative>] an array with all alternatives.
    def self.all
      all_names.map { |name| load(name) }
    end

    # @return [Alternative] an alternative with the given name.
    # @param name [String] The name of the alternative to be loaded.
    def self.load(name)
      raw_data = Cheetah.run("update-alternatives", "--query", name, stdout: :capture).lines
      return EmptyAlternative.new(name) unless raw_data.include?("\n")
      alternative = parse_to_map(raw_data.slice(0..raw_data.find_index("\n")))
      choices = raw_data.slice(raw_data.find_index("\n") + 1..raw_data.length)
      new(
        alternative["Name"],
        alternative["Status"],
        alternative["Value"],
        load_choices_from(choices)
      )
    end

    def self.parse_to_map(alternative_data)
      alternative = {}
      alternative_data.each do |line|
        key, value = line.split(":", 2)
        alternative[key.strip] = value.strip if !value.nil?
      end
      alternative
    end

    def self.load_choices_from(data)
      data.slice_before(/\AAlternative:/).map { |choice| load_choice(choice) }
    end

    def self.load_choice(data)
      map = to_map(data)
      Choice.new(map[:path], map[:priority], "")
    end

    def self.to_map(choice_data)
      {
        path:     choice_data[0].split.last,
        priority: choice_data[1].split.last
      }
    end

    def empty?
      false
    end

    def choice(new_choice_path)
      return unless choices.map(&:path).include?(new_choice_path)
      @value = new_choice_path
      @status = "manual"
    end

    private_class_method :all_names, :load_choices_from, :parse_to_map
    private_class_method :load_choice, :to_map
  end
  # Represents an alternative without any choice
  class EmptyAlternative < Alternative
    def initialize(name)
      super(name, "", "", [])
    end

    def empty?
      true
    end
  end
end
