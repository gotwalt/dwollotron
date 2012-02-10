class WelcomeController < ApplicationController
  def index
    redirect_to accounts_path
  end
end