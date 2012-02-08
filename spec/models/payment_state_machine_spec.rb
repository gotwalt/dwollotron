require 'spec_helper_lite'
require 'payment_state_machine'
require 'state_machine'

class PaymentStateMachineStub
  include PaymentStateMachine
  attr_accessor :state
  
  def log_payment_event(args=nil); end;
  def call_remote_dwolla_api(args=nil); end
  def complete_records(args=nil); end
  def set_account_error(args=nil); end
end

describe PaymentStateMachine do
  subject { PaymentStateMachineStub.new }

  describe 'waiting state' do
    it 'should be queued by default' do
      subject.should be_queued
    end
    
    it 'should log transitions' do
      subject.should_receive(:log_payment_event)
      subject.process
    end
    
    it 'can process' do
      subject.should_receive(:call_remote_dwolla_api)
      subject.process.should == true
      subject.should be_processing
    end
    
  end
  
  describe 'waiting state' do
    before do
      subject.state = "processing"
    end
    
    it 'should log transitions' do
      subject.should_receive(:log_payment_event)
      subject.complete
    end
    
    it 'can complete' do
      subject.should_receive(:complete_records)
      subject.complete.should == true
      subject.should be_completed
    end
    
  end
  
  describe 'error state' do
    before do
      subject.state = "processing"
    end
    
    it 'should log transitions' do
      subject.should_receive(:log_payment_event)
      subject.handle_error
    end
    
    it 'can complete' do
      subject.should_receive(:set_account_error)
      subject.handle_error.should == true
      subject.should be_error
    end
    
  end
end