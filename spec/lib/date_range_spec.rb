# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lib::DateRange, type: :class do
  describe 'DateRange valid?' do
    it 'tests if given string is a valid DateRange class' do
      expect(described_class.valid?('NotAClass')).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      expect(described_class.valid?('ddd')).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      expect(described_class.valid?('444')).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      expect(described_class.valid?('String')).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      expect(described_class.valid?('Lib::CurrentMonthDateRange')).to be_truthy # rubocop:disable RSpec/PredicateMatcher
    end
  end

  describe 'CurrentMonthDateRange' do
    it 'sets from date to first day of current month' do
      dr = Lib::CurrentMonthDateRange.new
      expect(dr.from_date).to eq(Date.new(Time.zone.today.year, Time.zone.today.month, 1))
    end

    it 'sets to date to last day of current month' do
      dr = Lib::CurrentMonthDateRange.new
      expect(dr.to_date).to eq(Date.new((Time.zone.today >> 1).year, (Time.zone.today >> 1).month, 1) - 1)
    end
  end

  describe 'PreviousMonthDateRange' do
    context 'when within calendar year' do
      before do
        fake_today = Date.parse('06-Sep-2015')
        allow(Time.zone).to receive(:today).and_return(fake_today)
      end

      it 'sets the date range to last month' do
        dr = Lib::PreviousMonthDateRange.new
        expect(dr.from_date).to eq(Date.parse('1-Aug-2015'))
        expect(dr.to_date).to eq(Date.parse('31-Aug-2015'))
      end
    end

    context 'when after 30 day month' do
      before do
        fake_today = Date.parse('09-May-2015')
        allow(Time.zone).to receive(:today).and_return(fake_today)
      end

      it 'sets the date range to last month' do
        dr = Lib::PreviousMonthDateRange.new
        expect(dr.from_date).to eq(Date.parse('1-Apr-2015'))
        expect(dr.to_date).to eq(Date.parse('30-Apr-2015'))
      end
    end

    context 'when it overlaps with calendar year' do
      before do
        fake_today = Date.parse('06-Jan-2015')
        allow(Time.zone).to receive(:today).and_return(fake_today)
      end

      it 'sets the date range to last month' do
        dr = Lib::PreviousMonthDateRange.new
        expect(dr.from_date).to eq(Date.parse('1-Dec-2014'))
        expect(dr.to_date).to eq(Date.parse('31-Dec-2014'))
      end
    end
  end

  describe 'CustomDateRange' do
    it 'sets from date and to date to those passed in as parameters' do
      dr = Lib::CustomDateRange.new(from_date: '2014-12-19', to_date: '2014-12-31')

      expect(dr.from_date).to eq(Date.new(2014, 12, 19))
      expect(dr.to_date).to eq(Date.new(2014, 12, 31))
    end

    it 'sets from date and to date to today if not supplied' do
      dr = Lib::CustomDateRange.new

      expect(dr.from_date).to eq(Time.zone.today)
      expect(dr.to_date).to eq(Time.zone.today)
    end
  end

  describe 'CurrentFinancialYearDateRange' do
    it 'sets from date to start of current financial year' do
      dr = Lib::CurrentFinancialYearDateRange.new
      expect(dr.from_date).to eq(
        Date.new(Time.zone.today.month > 6 ? Time.zone.today.year : Time.zone.today.year - 1, 7, 1)
      )
    end

    it 'sets to date to end of current financial year' do
      dr = Lib::CurrentFinancialYearDateRange.new
      expect(dr.to_date).to eq(
        Date.new(Time.zone.today.month > 6 ? Time.zone.today.year + 1 : Time.zone.today.year, 6, 30)
      )
    end
  end

  describe 'PreviousFinancialYearDateRange' do
    it 'sets from date to start of previous financial year' do
      dr = Lib::PreviousFinancialYearDateRange.new
      expect(dr.from_date).to eq(
        Date.new(Time.zone.today.month > 6 ? Time.zone.today.year - 1 : Time.zone.today.year - 2, 7, 1)
      )
    end

    it 'sets to date to end of previous financial year' do
      dr = Lib::PreviousFinancialYearDateRange.new
      expect(dr.to_date).to eq(
        Date.new(Time.zone.today.month > 6 ? Time.zone.today.year : Time.zone.today.year - 1, 6, 30)
      )
    end
  end

  describe 'Last90DaysDateRange' do
    it 'sets from date to 90 days ago' do
      dr = Lib::Last90DaysDateRange.new
      expect(dr.from_date).to eq(Time.zone.today - 90)
    end

    it 'sets to date to today' do
      dr = Lib::Last90DaysDateRange.new
      expect(dr.to_date).to eq(Time.zone.today)
    end
  end

  describe 'Last365DaysDateRange' do
    it 'sets from date to 365 days ago' do
      dr = Lib::Last365DaysDateRange.new
      expect(dr.from_date).to eq(Time.zone.today - 365)
    end

    it 'sets to date to today' do
      dr = Lib::Last365DaysDateRange.new
      expect(dr.to_date).to eq(Time.zone.today)
    end
  end

  describe 'Last12MonthsDateRange' do
    it 'sets from date to 12 months ago' do
      dr = Lib::Last12MonthsDateRange.new
      expect(dr.from_date).to eq(Date.new(Time.zone.today.year, Time.zone.today.month, 1) << 11)
    end

    it 'sets to date end of current month' do
      dr = Lib::Last12MonthsDateRange.new
      expect(dr.to_date).to eq(Date.new(Time.zone.today.year, Time.zone.today.month, -1))
    end
  end

  describe 'Last13MonthsDateRange' do
    before do
      fake_today = Date.parse('06-Sep-2015')
      allow(Time.zone).to receive(:today).and_return(fake_today)
    end

    it 'sets from date to 13 months ago' do
      dr = Lib::Last13MonthsDateRange.new
      expect(dr.from_date).to eq(Date.parse('1-Sep-2014'))
    end

    it 'sets to date end of current month' do
      dr = Lib::Last13MonthsDateRange.new
      expect(dr.to_date).to eq(Date.parse('30-Sep-2015'))
    end
  end
end
