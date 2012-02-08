require 'spec_helper'

describe Payment do
  subject { FactoryGirl.create(:payment) }
  
  describe '#log_payment_event' do
    let(:transition) { stub(:from_name => "from_name", :to_name => "to_name") }
    
    it 'should create a payment event record' do
      subject.raw_response = "raw_response"
      subject.remote_transaction_id = "remote_transaction_id"
      subject.error = "error"
      
      Timecop.freeze(Time.now) do
        event = subject.log_payment_event(transition)
        event.created_at.should == Time.now
        event.from_state.should == "from_name"
        event.to_state.should == "to_name"
        event.raw_response.should == "raw_response"
        event.remote_transaction_id.should == "remote_transaction_id"
        event.error.should == "error"
      end
    end
    
    it 'should reset the instrumentation instance variables' do
      subject.raw_response = "raw_response"
      subject.remote_transaction_id = "remote_transaction_id"
      subject.error = "error"
      subject.log_payment_event(transition)
      subject.raw_response.should be_nil
      subject.remote_transaction_id.should be_nil
      subject.error.should be_nil
    end
    
  end
  
  describe '#call_remote_dwolla_api' do
    before do
      subject.state = "processing"
      subject.stub(:has_existing_payments_in_the_same_effective_month?) { false }
    end
    
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.call_remote_dwolla_api
      end.should raise_error(Payment::InvalidStateError)
    end
    
    it "should call handle_duplicate! if there's a duplicate" do
      subject.stub(:has_existing_payments_in_the_same_effective_month?) { true }
      subject.stub(:handle_duplicate!) { true }
      subject.should_receive(:handle_duplicate!)
      subject.call_remote_dwolla_api
    end
    
    it 'should call the remote Dwolla api and update itself' do
      subject.stub(:complete!) { true }
      subject.should_receive(:complete!)
      subject.call_remote_dwolla_api
    end
    
    it 'should handle errors and call handle_error' do
      subject.stub(:handle_error!) { true }
      subject.account = nil
      subject.should_receive(:handle_error!)
      subject.call_remote_dwolla_api
      subject.error[:exception].should match /#\<NoMethodError/
      subject.error[:trace].class.should == Array
    end
  end
  
  describe '#complete_records' do
    before do
      subject.state = "completed"
    end
    
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.complete_records
      end.should raise_error(Payment::InvalidStateError)
    end
    
    it 'should update completed_at and call the account complete_transaction!' do
      subject.account.stub(:complete_transaction!) { true }
      subject.account.should_receive(:complete_transaction!)
      Timecop.freeze(Time.now) do
        subject.complete_records
        subject.completed_at.should == Time.now
      end  
      subject.should_not be_changed
    end
  end
  
  describe '#set_account_error' do
    before do
      subject.state = "error"
    end
    
    it 'should raise an InvalidStateError unless the state machine is correct' do
      lambda do
        subject.state = "queued"
        subject.set_account_error
      end.should raise_error(Payment::InvalidStateError)
    end
    
    it "should call the account's handle_error!" do
      subject.account.stub(:handle_error!) { true }
      subject.account.should_receive(:handle_error!)
      subject.set_account_error
    end
  end
  
  
  
  describe '#has_existing_payments_in_the_same_effective_month?' do
    it 'should return false with only one payment' do
      subject.should_not be_has_existing_payments_in_the_same_effective_month
    end
    
    it "should return true when there's a second one" do
      subject.update_attributes(:state => "completed")
      invalid_subject = FactoryGirl.build(:payment, :account => subject.account)
      invalid_subject.should be_has_existing_payments_in_the_same_effective_month
    end
    
  end

end