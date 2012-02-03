require 'spec_helper'

describe AccountAmount do
  let(:account) { FactoryGirl.create(:account) }
  subject { FactoryGirl.build(:account_amount, :account => account) }
  
  describe '#account_can_have_no_more_than_one_of_these_per_day validator' do
    
    before do
      subject.save!
    end
    
    it 'should not allow more than one account_amount per account per day' do
      bad_one = FactoryGirl.build(:account_amount, :account => account)
      bad_one.should_not be_valid
      bad_one.errors_on(:active_at).should_not be_nil
    end
    
    it 'should allow for an active_at for the day after the last account_amount' do
      good_one = FactoryGirl.build(:account_amount, :account => account, :active_at => 1.day.from_now)
      good_one.should be_valid
    end
    
    it 'should allow for an active_at for the day before the last account_amount' do
      good_one = FactoryGirl.build(:account_amount, :account => account, :active_at => 1.day.ago)
      good_one.should be_valid
    end
    
    it 'should allow for account_amounts on the same day for different accounts' do
      good_one = FactoryGirl.build(:account_amount)
      good_one.should be_valid
    end
  end
end