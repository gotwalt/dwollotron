module DwollaAccount
  
  def dwolla_account
    @dwolla_account ||= Dwolla::User.me(access_token)
  end
  
  def dwolla_account_valid?
    begin
      dwolla_account.fetch
      true
    rescue Dwolla::RequestException => ex
      false
    end
  end
  
  def dwolla_user_info
    @dwolla_user_info ||= dwolla_account.fetch
  end
  
  def dwolla_destination_account
    Dwollotron::Application.config.dwolla.account  
  end
  
  def send_money(amount)
    dwolla_account.send_money_to(dwolla_destination_account, pin, amount)
  end
  
end