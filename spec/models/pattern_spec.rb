# frozen_string_literal: true

require 'rails_helper'
#
#  Pattern
#
#  id: int, primary key
#  account_id: int, foreign key
#  match_text: string
#  category_id: int, foreign key
#  subcategory_id: int foreign key
#
RSpec.describe Pattern do
  it 'has a valid factory' do
    p = FactoryBot.create(:pattern)
    expect(p).to be_valid
    expect(p).to be_a(described_class)
  end

  describe 'validations' do
    it 'is valid without an account' do
      expect(FactoryBot.build(:pattern, account: nil)).to be_valid
    end

    it 'is invalid without a category' do
      expect(FactoryBot.build(:pattern, category: nil)).not_to be_valid
    end

    it 'is valid without a subcategory' do
      expect(FactoryBot.build(:pattern, subcategory: nil)).to be_valid
    end

    it 'is invalid without match text' do
      expect(FactoryBot.build(:pattern, match_text: nil)).not_to be_valid
    end

    it 'is valid without notes' do
      expect(FactoryBot.build(:pattern, notes: nil)).to be_valid
    end
  end

  describe 'relationships' do
    it 'can belong to account' do
      a = FactoryBot.create(:account)
      expect(FactoryBot.create(:pattern, account: a).account).to eq(a)
    end

    it 'belongs to category' do
      c = FactoryBot.create(:category)
      expect(FactoryBot.create(:pattern, category: c).category).to eq(c)
    end

    it 'belongs to subcategory' do
      s = FactoryBot.create(:subcategory)
      expect(FactoryBot.create(:pattern, subcategory: s).subcategory).to eq(s)
    end
  end
end
