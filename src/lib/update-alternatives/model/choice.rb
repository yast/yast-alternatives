module UpdateAlternatives
  # Represent a choice of an alternative
  class Choice
    attr_reader :path
    attr_reader :priority
    attr_reader :slaves

    def initialize(path, priority, slaves)
      @path = path
      @priority = priority
      @slaves = slaves
    end
  end
end
