# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PatternsController do
  describe 'GET index' do
    it 'returns all patterns' do
      pattern = FactoryBot.create(:pattern)

      get :index

      json = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(json['patterns'].length).to eq(1)
      expect(json['patterns'][0]).to eq(serialized_pattern(pattern))
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Pattern' do
        category = FactoryBot.create(:category)
        subcategory = FactoryBot.create(:subcategory)
        pattern_attrs = FactoryBot.attributes_for(
          :pattern,
          category_id: category.id,
          subcategory_id: subcategory.id
        )

        expect do
          post :create, params: { pattern: pattern_attrs }
        end.to change(Pattern, :count).by(1)

        expect(response).to have_http_status(:created)

        json = response.parsed_body
        pattern = Pattern.first
        expect(json['pattern']).to eq(serialized_pattern(pattern))
      end
    end

    describe 'with invalid params' do
      it 'returns an error and does not create the pattern' do
        category = FactoryBot.create(:category)
        pattern = FactoryBot.attributes_for(:pattern, category_id: category.id, match_text: nil)

        expect do
          post :create, params: {
            pattern:
          }
        end.not_to change(Pattern, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json).to eq('match_text' => ["can't be blank"])
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      it 'updates the requested pattern' do
        pattern = FactoryBot.create(:pattern)
        new_subcategory = FactoryBot.create(:subcategory)
        new_category = new_subcategory.category

        put :update, params: { id: pattern.id, pattern: {
          match_text: 'New Text',
          notes: 'New Note',
          category_id: new_category.id,
          subcategory_id: new_subcategory.id
        } }

        pattern.reload
        expect(pattern.match_text).to eq('New Text')
        expect(pattern.notes).to eq('New Note')
        expect(pattern.category).to eq(new_category)
        expect(pattern.subcategory).to eq(new_subcategory)

        json = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(json['pattern']).to eq(serialized_pattern(pattern))
      end
    end

    context 'with invalid params' do
      it 'assigns the pattern as @pattern' do
        pattern = FactoryBot.create(:pattern)

        put :update, params: {
          id: pattern.id,
          pattern: FactoryBot.attributes_for(:pattern_invalid)
        }

        json = response.parsed_body
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to eq('match_text' => ["can't be blank"])
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested pattern' do
      pattern = FactoryBot.create(:pattern)

      expect do
        delete :destroy, params: { id: pattern.id }
      end.to change(Pattern, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  def serialized_pattern(pattern)
    {
      'id' => pattern.id,
      'category_id' => pattern.category_id,
      'subcategory_id' => pattern.subcategory_id,
      'match_text' => pattern.match_text,
      'notes' => pattern.notes
    }
  end
end
