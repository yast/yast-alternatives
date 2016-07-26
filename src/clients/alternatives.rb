require "y2_alternatives/dialog/list_alternatives"

Yast.import "Confirm"

# Checks if user is root and create a ListAlternatives dialog
class AlternativesClient
  def main
    Y2Alternatives::Dialog::ListAlternatives.run if Yast::Confirm.MustBeRoot
  end
end

AlternativesClient.new.main
