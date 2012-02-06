require 'spec_helper'

describe Account do
  subject { FactoryGirl.create(:account) }

  describe '#amount_at' do
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