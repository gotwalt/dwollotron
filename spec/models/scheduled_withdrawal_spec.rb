require 'spec_helper'

describe ScheduledWithdrawal do
  let(:account) { FactoryGirl.create(:account) }
  subject { FactoryGirl.build(:scheduled_withdrawal, :account => account, :day_of_month => 15) }
  
  it 'should provide usable info' do
    ScheduledWithdrawal.count.should == 0
    subject.save!
    
    ScheduledWithdrawal.count.should == 1
    subject.should_not be_has_existing_active_scheduled_sibling_withdrawl
    
    peer = FactoryGirl.build(:scheduled_withdrawal, :account => account)
    peer.should be_has_existing_active_scheduled_sibling_withdrawl
  end
  
  describe 'validations' do
    before do
      subject.save!
    end
    
    after do
      #Timecop.return
    end
    
    it 'should allow addition of ScheduledWithdrawals if the effective_at is at least in next month' do
      new_rule = FactoryGirl.build(:scheduled_withdrawal, :account => account, :effective_at => Time.now.at_beginning_of_month.next_month)
      new_rule.valid?
      new_rule.should be_valid
    end
  
    it 'should not allow creation of ScheduledWithdrawals that are effective_at in the past' do
      new_rule = FactoryGirl.build(:scheduled_withdrawal, :account => account, :effective_at => 1.minute.ago)
      new_rule.should_not be_valid
    end
  
    it 'should not allow addition of ScheduledWithdrawals if the effective_at is in the current month' do
      new_rule = FactoryGirl.build(:scheduled_withdrawal, :account => account, :effective_at => Time.now.getgm.end_of_month)
      new_rule.should_not be_valid
    end
    
  end
end