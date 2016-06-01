require "cheetah"

module UpdateAlternatives
  # Represents an alternative
  class Alternative
    attr_reader :name
    attr_reader :status
    attr_reader :value
    attr_reader :choices
    Choice = Struct.new(:path, :priority, :slaves)

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
      all_names.map { |name| load(name) }
    end

    def self.load(name)
      raw_data = Cheetah.run("update-alternatives", "--query", name, stdout: :capture).lines

      split = raw_data.find_index("\n")
      alternative_data = raw_data[0...split]
      choices = raw_data[split + 1..raw_data.length]

      alternative = parse_alternative_data(alternative_data)
      choices_map = parse_choices(choices)
      new(alternative["Name:"], alternative["Status:"], alternative["Value:"], choices_map)
    end

    def self.parse_alternative_data(alternative_data)
      alternative = {}
      alternative_data.each do |line|
        alternative[line.split.first] = line.split.last
      end
      alternative
    end

    def self.parse_choices(choices)
      choices_map = {}
      choice = {}
      choices.each do |line|
        if line == "\n"
          choices_map[choice["Alternative:"]] = Choice.new(
            choice["Alternative:"], choice["Priority:"], ""
          )
        else
          choice[line.split.first] = line.split.last
        end
      end
      choices_map[choice["Alternative:"]] = Choice.new(
        choice["Alternative:"], choice["Priority:"], ""
      )
      choices_map
    end
    private_class_method :all_names, :parse_choices, :parse_alternative_data
  end
end
