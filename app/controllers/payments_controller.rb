class PaymentsController < ApplicationController

  def show
    @payment = Payment.find(params[:id])
    @payment_events = @payment.payment_events.order(:created_at)
  end

end