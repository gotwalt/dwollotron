require 'spec_helper'

describe ScheduledAmount do
  let(:account) { FactoryGirl.create(:account) }
  subject { FactoryGirl.create(:scheduled_amount, :account => account) }
  
  before do
    subject.save!
  end
  
  describe '#account_can_have_no_more_than_one_of_these_per_day validator' do
    it 'should not allow more than one scheduled_amount per account per day' do
      bad_one = FactoryGirl.build(:scheduled_amount, :account => account)
      bad_one.should_not be_valid
      bad_one.errors_on(:effective_at).should_not be_nil
    end
    
    it 'should allow for an effective_at for the day after the last scheduled_amount' do
      good_one = FactoryGirl.build(:scheduled_amount, :account => account, :effective_at => 1.day.from_now)
      good_one.should be_valid
    end
    
    it 'should allow for an effective_at for the day before the last scheduled_amount' do
      good_one = FactoryGirl.build(:scheduled_amount, :account => account, :effective_at => 1.day.ago)
      good_one.should be_valid
    end
    
    it 'should allow for scheduled_amounts on the same day for different accounts' do
      good_one = FactoryGirl.build(:scheduled_amount)
      good_one.should be_valid
    end
    
  end
end