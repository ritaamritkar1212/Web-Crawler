require 'rails_helper'

RSpec.describe 'Sitemap index request', type: :request do

  describe 'GET /sitemap' do
    it 'returns sitemap of a domain in json format' do
      get "/sitemap"

      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
      expect(response).to match_json_schema('sitemap_index')
    end
  end
end