# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DateRangeOptionsController do
  describe 'GET index' do
    it 'returns a list of all account types' do
      get :index

      expect(response).to have_http_status(:ok)
      json = response.parsed_body

      expect(json['date_range_options'].length).to eq(8)
      expect(json['date_range_options'][0]).to include(
        'id' => 1,
        'name' => 'Current Month',
        'default' => true,
        'custom' => false
      )
      expect(json['date_range_options'][0]).to have_key('from_date')
      expect(json['date_range_options'][0]).to have_key('to_date')

      expect(json['date_range_options'][1]).to include(
        'id' => 2,
        'name' => 'Previous Month',
        'default' => false,
        'custom' => false
      )
      expect(json['date_range_options'][2]).to include(
        'id' => 3,
        'name' => 'Custom Dates',
        'default' => false,
        'custom' => true
      )
      expect(json['date_range_options'][3]).to include(
        'id' => 4,
        'name' => 'Current Financial Year',
        'default' => false,
        'custom' => false
      )
      expect(json['date_range_options'][4]).to include(
        'id' => 5,
        'name' => 'Previous Financial Year',
        'default' => false,
        'custom' => false
      )
      expect(json['date_range_options'][5]).to include(
        'id' => 6,
        'name' => 'Last 90 Days',
        'default' => false,
        'custom' => false
      )
      expect(json['date_range_options'][6]).to include(
        'id' => 7,
        'name' => 'Last 12 Months',
        'default' => false,
        'custom' => false
      )
      expect(json['date_range_options'][7]).to include(
        'id' => 8,
        'name' => 'Last 365 Days',
        'default' => false,
        'custom' => false
      )
    end
  end
end
