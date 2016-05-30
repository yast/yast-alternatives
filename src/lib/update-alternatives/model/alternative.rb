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

      name = filter(raw_data, /Name: /)
      status = filter(raw_data, /Status: /)
      value = filter(raw_data, /Value: /)

      alternative = filter(raw_data, /Alternative: /)
      priority = filter(raw_data, /Priority: /)
      slaves = ""

      choice = UpdateAlternatives::Choice.new(alternative, priority, slaves)
      choice_map = { alternative => choice }
      UpdateAlternatives::Alternative.new name, status, value, choice_map
    end

    def self.filter(text, regular_expresion)
      text.grep(regular_expresion) { |line| line.split.last }.first
    end
  end
end
