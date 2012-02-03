require 'spec_helper'

describe Account do
  subject { FactoryGirl.create(:account) }

  describe '#amount_at' do
    let(:too_little) { FactoryGirl.create(:account_amount, :account=> subject, :active_at => 10.days.ago) }
    let(:too_big) { FactoryGirl.create(:account_amount, :account=> subject, :active_at => 10.days.from_now) }
    let(:just_right) { FactoryGirl.create(:account_amount, :account=> subject, :active_at => 2.days.ago) }
    
    before do
      too_little.save!
      too_big.save!
      just_right.save!
    end
    
    it 'should retrieve the correct account_amount for right now' do
      subject.amount_at(Time.now).should == just_right
    end
  
    it 'should retrieve the correct account_amount for a while ago' do
      subject.amount_at(6.days.ago).should == too_little
    end
    
    it 'should retrieve the correct account_amount for a bit from now' do
      subject.amount_at(12.days.from_now).should == too_big
    end
  end
  
  describe '#current_amount' do
    
    before do
      subject = double("account")
    end
    
    it 'should call #amount_at with the current time' do
      Timecop.freeze do
        subject.should_receive(:amount_at).with(Time.now)
        subject.current_amount
      end
    end
  end
end