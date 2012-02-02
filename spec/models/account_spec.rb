require 'spec_helper'

describe Account do
  subject { FactoryGirl.build(:account) }
  
  it 'should be an Account' do
    subject.class.should == Account
  end
end