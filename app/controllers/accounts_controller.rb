class AccountsController < ApplicationController
  def index
    @accounts = Account.order("id")
  end
  
  def new
    @account = Account.new
    @account.scheduled_amounts.new
    @account.scheduled_withdrawals.new
  end
  
  def create
    effective_at = Time.now
    @account = Account.create params[:account]
    if @account.persisted?
      @account.scheduled_withdrawals.create!(:effective_at => effective_at, :day_of_month => params[:day_of_month])
      @account.scheduled_amounts.create!(:effective_at => effective_at, :amount => params[:amount])
      redirect_to account_path(@account)
    else
      flash[:error] = @account.errors.full_messages.to_sentence
      render :new
    end
  end
  
  def show
    @account = Account.find(params[:id])
    @scheduled_withdrawals = @account.scheduled_withdrawals.order(:effective_at)
    @scheduled_amounts = @account.scheduled_amounts.order(:effective_at)
    @payments = @account.payments.order(:started_at)
  end
  
  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_path
  end
  
  def queue
    account = Account.find(params[:id])
    account.queue!
    redirect_to account_path(account)
  end

  def cancel_current_payment
    account = Account.find(params[:id])
    begin
      account.cancel_current_payment
    rescue Account::InvalidStateError => ex
      # no-op. It's already been processed, do nothing
    end
    redirect_to account_path(account)
  end
end