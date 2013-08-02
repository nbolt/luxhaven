if Rails.env.production?
  code   = 'b2bkhq0wa5'
  secret = 'ls3trt7evf'
else
  code   = 'rswcz0805u'
  secret = 'kcoyuj0ri1'
end

if Rails.env.test?
  disabled = true
else
  disabled = false
end


Preact.configure do |config|
  config.code     = code
  config.secret   = secret
  config.disabled = disabled
end

