Dwollotron::Application.configure do
  c = Struct.new(:key, :secret, :account)
  config.dwolla = c.new
  config.dwolla.key = "dsUcI/qPmnWehQsJGyUJNzVJa5SG2dMIA000By4YU8OA+7MIhJ"
  config.dwolla.secret = "P48HPkf7BcU3ChOi/WNX6Fz4XmNDPc+oAQ4XmvIrPKLzMHfaGW"
  config.dwolla.account = "812-552-6232"
end