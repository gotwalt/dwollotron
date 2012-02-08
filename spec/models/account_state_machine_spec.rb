require 'spec_helper_lite'
require 'account_state_machine'
require 'state_machine'

class AccountStateMachineStub
  include AccountStateMachine
  attr_accessor :state
  
  def create_new_payment(args=nil); end;
  def update_account_record(args=nil); end
  def cancel_current_payment(args=nil); end
end

describe AccountStateMachine do
  subject { AccountStateMachineStub.new }

  describe 'transaction_completed state' do
    before do
      subject.state = "transaction_completed"
    end
    
    it 'can finalize and go to waiting state' do
      subject.finalize_records.should == true
      subject.should be_waiting
    end
    
    it "can't do anything else" do
      valid_paths = [:handle_error, :finalize_records]
      paths = subject.state_paths.events - valid_paths
      paths.each do |path|
        lambda do
          subject.send("#{path}!".to_sym)
        end.should raise_error(StateMachine::InvalidTransition)
        subject.should be_transaction_completed
      end
    end
    
  end
  
  
  
  describe 'error state' do
    before do
      subject.state = "error"
    end
    
    it 'can recover_from_error' do
      subject.should_receive(:cancel_current_payment)
      subject.recover_from_error.should == true
      subject.should be_waiting
    end
    
    it "can't do anything else" do
      valid_paths = [:recover_from_error]
      paths = subject.state_paths.events - valid_paths
      paths.each do |path|
        lambda do
          subject.send("#{path}!".to_sym)
        end.should raise_error(StateMachine::InvalidTransition)
        subject.should be_error
      end
    end
    
  end
  
  
  describe 'queued state' do
    before do
      subject.state = "queued"
    end
    
    it 'can complete transaction' do
      subject.should_receive(:update_account_record)
      subject.complete_transaction.should == true
      subject.should be_transaction_completed
    end
    
    it "can't do anything else" do
      valid_paths = [:handle_error, :complete_transaction]
      paths = subject.state_paths.events - valid_paths
      paths.each do |path|
        lambda do
          subject.send("#{path}!".to_sym)
        end.should raise_error(StateMachine::InvalidTransition)
        subject.should be_queued
      end
    end
    
    it "can go to the error state" do
      subject.handle_error.should == true
      subject.should be_error
    end
  end
  
  describe 'waiting state' do
    it 'can queue' do
      subject.should_receive(:create_new_payment)
      subject.queue.should == true
      subject.should be_queued
    end

    it "can't do anything else" do
      valid_paths = [:queue]
      paths = subject.state_paths.events - valid_paths
      paths.each do |path|
        lambda do
          subject.send("#{path}!".to_sym)
        end.should raise_error(StateMachine::InvalidTransition)
        subject.should be_waiting
      end
    end
    
  end
end