require "cheetah"

module UpdateAlternatives
  # Represents an alternative
  class Alternative
    attr_reader :name
    attr_reader :status
    attr_reader :value
    attr_reader :choices
    # Represents a Choice of an alternative.
    Choice = Struct.new(:path, :priority, :slaves)

    # Creates a new Alternative with the given parameters.
    #
    # @param name [String] Name of the alternative.
    # @param status [String] Status of the alternative, it can be auto or manual.
    # @param value [String] Path of the actual choice.
    # @param choices [Array<Choice>] Contains all Alternative's Choices.
    def initialize(name, status, value, choices)
      @name = name
      @status = status
      @value = value
      @choices = choices
    end

    # Read all names of the alternatives on the system.
    def self.all_names
      raw_data = Cheetah.run("update-alternatives", "--get-selections", stdout: :capture).lines
      raw_data.map { |string| string.split.first }
    end

    # Load all alternatives that exist in the system.
    def self.all
      all_names.map { |name| load(name) }
    end

    # Load an alternative.
    # @param name [String] The name of the alternative to be loaded.
    def self.load(name)
      raw_data = Cheetah.run("update-alternatives", "--query", name, stdout: :capture).lines
      alternative = parse_to_map(raw_data.slice(0..raw_data.find_index("\n")))
      choices = raw_data.slice(raw_data.find_index("\n") + 1..raw_data.length)
      new(
        alternative["Name:"],
        alternative["Status:"],
        alternative["Value:"],
        load_choices_from(choices)
      )
    end

    def self.parse_to_map(alternative_data)
      alternative = {}
      alternative_data.each do |line|
        alternative[line.split.first] = line.split.last
      end
      alternative
    end

    def self.load_choices_from(data)
      choices_list = []
      while more_than_one_choice?(data)
        choices_list << load_choice(data.slice!(0..data.find_index("\n")))
      end
      choices_list << load_choice(data)
    end

    def self.more_than_one_choice?(data)
      !data.find_index("\n").nil?
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

    private_class_method :all_names, :load_choices_from, :parse_to_map
    private_class_method :more_than_one_choice?, :load_choice, :to_map
  end
end
