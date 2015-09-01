require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the JsonApiHelper. For example:
#
# describe JsonApiHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe JsonApiHelper, type: :helper do

  it { is_expected.to respond_to :json_api_params }
  it { is_expected.to respond_to :json_api_related_resources }
  it { is_expected.to respond_to :json_api_format? }

end
