require "rails_helper"

RSpec.describe MortalityTrackingJob do
  let(:filename) { "example_of_mortality_tracking_data.csv" }

  it_behaves_like "import job"
end

