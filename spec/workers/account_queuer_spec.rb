require 'spec_helper'

describe AccountQueuer do
  let(:account) { FactoryGirl.create(:account) }
  before do
    account.scheduled_withdrawals.create!(:day_of_month => Time.now.getgm.day, :effective_at => Time.now)
    Account.stub(:waiting).and_return([account])
  end
  
  it 'should find a transaction and start the processing' do
    account.should_receive(:queue)
    AccountQueuer.perform.should == 1
  end
  
end