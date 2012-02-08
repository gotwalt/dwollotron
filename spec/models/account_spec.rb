require 'spec_helper'

describe Account do
  subject { FactoryGirl.create(:account) }
  
  describe '#create_new_payment' do
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.create_new_payment
      end.should raise_error(Account::InvalidStateError)
    end
    
    it 'should raise an ArgumentError if there is a current_payment_id' do
      lambda do
        subject.current_payment_id = 1
        subject.create_new_payment
      end.should raise_error(ArgumentError)
    end
    
    it 'should create a payment record and update itself' do
      
      Timecop.freeze(Time.now) do
        subject.create_new_payment
        subject.current_payment_id.should_not be_nil
        payment = Payment.find(subject.current_payment_id)
      
        payment.account_id.should == subject.id
        payment.started_at.should == Time.now
        payment.effective_at.should == Time.now
      end
      
    end
  end
  
  describe '#update_account_record' do
    before do
      subject.queue
      subject.state = "transaction_completed"
    end
    
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.update_account_record
      end.should raise_error(Account::InvalidStateError)
    end
    
    it 'should raise an ArgumentError unless there is a current_payment_id' do
      lambda do
        subject.current_payment_id = nil
        subject.update_account_record
      end.should raise_error(ArgumentError)
    end
    
    it "should set the current_payment_id to nil because we're done with it" do
      subject.update_account_record
      subject.current_payment_id.should be_nil
      subject.current_payment.should be_nil
      subject.should_not be_changed
    end
    
  end
  
  describe '#cancel_current_payment' do
    before do
      subject.queue
      subject.state = "error"
      subject.current_payment.stub(:cancel!) { true }
    end
    
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.cancel_current_payment
      end.should raise_error(Account::InvalidStateError)
    end
    
    it 'should raise an ArgumentError unless there is a current_payment_id' do
      lambda do
        subject.current_payment_id = nil
        subject.cancel_current_payment
      end.should raise_error(ArgumentError)
    end
    
    it "should set the current_payment_id to nil because we're done with it" do
      subject.current_payment.should_receive(:cancel!)
      subject.cancel_current_payment
      subject.current_payment_id.should be_nil
      subject.current_payment.should be_nil
      subject.should_not be_changed
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