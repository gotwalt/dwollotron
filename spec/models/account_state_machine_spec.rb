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

  describe 'initial state' do

    it 'can transition to waiting' do
      subject.queue
      subject.should be_queued
    end

    it "can't transition to finalized" do
      lambda do
        subject.finalize_records!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
    
    it "can't transition to transaction_completed" do
      lambda do
        subject.complete_transaction!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
    
    it "can't transition to error" do
      lambda do
        subject.handle_error!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
  end
  
  describe 'queued state' do

    it 'can transition to waiting' do
      subject.queue
      subject.should be_queued
    end

    it "can't transition to finalized" do
      lambda do
        subject.finalize_records!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
    
    it "can't transition to transaction_completed" do
      lambda do
        subject.complete_transaction!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
    
    it "can't transition to error" do
      lambda do
        subject.handle_error!
      end.should raise_error(StateMachine::InvalidTransition)
      subject.should be_waiting
    end
  end
end