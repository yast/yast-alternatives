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

      alternative_data = raw_data[0...empty_line_index_in(raw_data)]
      choices_data = raw_data[empty_line_index_in(raw_data) + 1..raw_data.length]

      alternative = parse_alternative_data(alternative_data)
      new(alternative["Name:"], alternative["Status:"], alternative["Value:"], load_choices_from(choices_data))
    end

    def self.parse_alternative_data(alternative_data)
      alternative = {}
      alternative_data.each do |line|
        alternative[line.split.first] = line.split.last
      end
      alternative
    end

    def self.load_choices_from(data)
      choices_list = []
      while empty_line_index_in(data) != nil
        choices_list << create_choice(data.slice!(0..empty_line_index_in(data)))
      end
      choices_list << create_choice(data)
    end

    def self.create_choice(choice)
      Choice.new(choice[0].split.last, choice[1].split.last, "")
    end

    def self.empty_line_index_in(array)
      array.find_index("\n")
    end
    private_class_method :all_names, :load_choices_from, :parse_alternative_data
  end
end
