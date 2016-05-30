require "cheetah"

module UpdateAlternatives
  # Represents an alternative
  class Alternative
    attr_reader :name
    attr_reader :status
    attr_reader :value
    attr_reader :choices

    def initialize(name, status, value, choices)
      @name = name
      @status = status
      @value = value
      @choices = choices
    end

    def self.all_names
      raw_data = Cheetah.run("update-alternatives", "--get-selections", stdout: :capture).lines
      raw_data.map { |string| string.split.first }
    end

    def self.all
      list = all_names
      list.map { |name| query(name) }
    end

    def self.query(name)
      raw_data = Cheetah.run("update-alternatives", "--query", name, stdout: :capture).lines

      name = raw_data.grep(/Name: /) { |line| line.split.last }.first
      status = raw_data.grep(/Status: /) { |line| line.split.last }.first
      value = raw_data.grep(/Value: /) { |line| line.split.last }.first

      alternative = raw_data.grep(/Alternative: /) { |line| line.split.last }.first
      priority = raw_data.grep(/Priority: /) { |line| line.split.last }.first
      slaves = ""

      choice = UpdateAlternatives::Choice.new(alternative, priority, slaves)
      choice_map = { alternative => choice }
      UpdateAlternatives::Alternative.new name, status, value, choice_map
    end
  end
end
