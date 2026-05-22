module Weather
  class SearchFormComponent < ViewComponent::Base
    def initialize(url:, compact: false)
      @url = url
      @compact = compact
    end
  end
end
