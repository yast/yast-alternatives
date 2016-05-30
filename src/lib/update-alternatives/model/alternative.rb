require "cheetah"

module UpdateAlternatives
  # Represents an alternative
  class Alternative
    def self.all_names
      raw_data = Cheetah.run("update-alternatives", "--get-selections", stdout: :capture).lines
      raw_data.map { |string| string.split.first }
    end
  end
end
