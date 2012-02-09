require 'spec_helper'

describe PaymentProcessor do
  let(:payment) { FactoryGirl.build(:payment, :state => "queued") }
  before do
    Payment.stub(:find).and_return(payment)
    payment.stub(:process) { true }
  end
  
  it 'should find a transaction and start the processing' do
    payment.should_receive(:process)
    PaymentProcessor.perform(payment.id)
  end
  
end