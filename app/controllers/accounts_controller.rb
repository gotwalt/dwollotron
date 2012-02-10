class AccountsController < ApplicationController
  def index
    @accounts = Account.all
  end
  
  def show
    @account = Account.find(params[:id])
    @scheduled_withdrawals = @account.scheduled_withdrawals.order(:effective_at)
    @scheduled_amounts = @account.scheduled_amounts.order(:effective_at)
    @payments = @account.payments.order(:started_at)
  end

end