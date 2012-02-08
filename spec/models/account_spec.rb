require 'spec_helper'

describe Account do
  subject { FactoryGirl.create(:account) }
  
  describe "state machine" do
    it 'should be in waiting state by default' do
      subject.state_name.should == :waiting
    end
  end
  

  describe '#scheduled_amount_at' do
    let(:too_little) { FactoryGirl.create(:scheduled_amount, :account=> subject, :effective_at => 10.days.ago) }
    let(:too_big) { FactoryGirl.create(:scheduled_amount, :account=> subject, :effective_at => 10.days.from_now) }
    let(:just_right) { FactoryGirl.create(:scheduled_amount, :account=> subject, :effective_at => 2.days.ago) }
    
    before do
      too_little.save!
      too_big.save!
      just_right.save!
    end
    
    it 'should retrieve the correct scheduled_amount for right now' do
      subject.scheduled_amount_at(Time.now).should == just_right
    end
  
    it 'should retrieve the correct scheduled_amount for a while ago' do
      subject.scheduled_amount_at(6.days.ago).should == too_little
    end
    
    it 'should retrieve the correct scheduled_amount for a bit from now' do
      subject.scheduled_amount_at(12.days.from_now).should == too_big
    end
  end
  
  describe '#scheduled_withdrawal_at' do
    let(:too_little) { FactoryGirl.build(:scheduled_withdrawal, :account=> subject, :effective_at => 3.months.ago) }
    let(:too_big) { FactoryGirl.build(:scheduled_withdrawal, :account=> subject, :effective_at => 1.month.from_now) }
    let(:just_right) { FactoryGirl.build(:scheduled_withdrawal, :account=> subject, :effective_at => 1.month.ago) }
    
    before do
      too_little.save(:validate => false)
      too_big.save(:validate => false)
      just_right.save(:validate => false)
    end
    
    it 'should retrieve the correct scheduled_amount for right now' do
      subject.scheduled_withdrawal_at(Time.now).should == just_right
    end
  
    it 'should retrieve the correct scheduled_amount for a while ago' do
      subject.scheduled_withdrawal_at(6.weeks.ago).should == too_little
    end
    
    it 'should retrieve the correct scheduled_amount for a bit from now' do
      subject.scheduled_withdrawal_at(2.months.from_now).should == too_big
    end
  end
  
  describe '#current_amount' do
    
    before do
      subject = double("account")
    end
    
    it 'should call #amount_at with the current time' do
      Timecop.freeze do
        subject.should_receive(:scheduled_amount_at).with(Time.now)
        subject.current_amount
      end
    end
  end
end