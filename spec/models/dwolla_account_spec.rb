require 'spec_helper_lite'
require 'dwolla_account'
require 'dwolla'

class DwollaAccountStub
  include DwollaAccount
  
  attr_accessor :access_token, :pin
  
  def initialize
    self.access_token = "test-token"
    self.pin = "1234"
  end
end

if !defined?(Dwollotron)
  class Dwollotron
  end
  class Dwollotron::Application
    def self.config
      config = Struct.new(:dwolla).new
      config.dwolla = Struct.new(:key, :secret, :account).new
      config.dwolla.account = "1234"
      config
    end
  end
end

describe DwollaAccount do
  subject { DwollaAccountStub.new }
  
  describe '#dwolla_account' do
    it 'should return a dwolla user' do
      Dwolla::User.should_receive(:me).with(subject.access_token).and_return(true)
      subject.dwolla_account.should == true
    end
    
    it 'should cache the account' do
      Dwolla::User.stub(:me).and_return(1,2,3,4)
      info1 = subject.dwolla_account
      info1.should == subject.dwolla_account
    end
  end
  
  describe '#dwolla_account_valid?' do
    it "should return true when fetching the user doesn't blow up" do
      subject.dwolla_account.stub(:fetch).and_return(true)
      subject.should be_dwolla_account_valid
    end
    
    it "should return false when fetching the user fails" do
      subject.dwolla_account.stub(:fetch).and_raise(Dwolla::RequestException.new)
      subject.should_not be_dwolla_account_valid
    end
  end
  
  describe '#dwolla_user_info' do
    it 'should return information from the dwolla API' do
      subject.dwolla_account.stub(:fetch).and_return(true)
      subject.dwolla_account.should_receive(:fetch)
      subject.dwolla_user_info.should == true
    end
    
    it 'should cache the info' do
      subject.dwolla_account.stub(:fetch).and_return(1,2,3,4)
      info1 = subject.dwolla_user_info
      info1.should == subject.dwolla_user_info
    end
  end
  
  describe '#dwolla_destination_account' do
    it 'should return the configured destination account' do
      Dwollotron::Application.config.dwolla.stub(:account).and_return("1234")
      subject.dwolla_destination_account.should == "1234"
    end
  end
  
  describe '#send_money' do
    it 'should send the correct parameters to the Dwolla API' do
      amount = 10
      subject.stub(:dwolla_destination_account).and_return('dummy-account')
      subject.dwolla_account.should_receive(:send_money_to).with('dummy-account', subject.pin, amount).and_return(true)
      subject.send_money(amount).should == true
    end
  end
  
end