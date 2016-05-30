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
      list.map { |name| load(name) }
    end

    def self.load(name)
      raw_data = Cheetah.run("update-alternatives", "--query", name, stdout: :capture).lines

      name = filter(raw_data, /Name: /).first
      status = filter(raw_data, /Status: /).first
      value = filter(raw_data, /Value: /).first

      alternatives = filter(raw_data, /Alternative: /)
      priorities = filter(raw_data, /Priority: /)

      choice_map = {}

      until alternatives.empty?
        choice = UpdateAlternatives::Choice.new(alternatives.pop, priorities.pop, "")
        choice_map[choice.path] = choice
      end

      UpdateAlternatives::Alternative.new(name, status, value, choice_map)
    end

    def self.filter(text, regular_expresion)
      text.grep(regular_expresion) { |line| line.split.last }
    end
  end
end
