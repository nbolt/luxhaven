Preact.configure do |config|
  config.code   = 'b2bkhq0wa5'
  config.secret = 'ls3trt7evf'

  config.disabled = Rails.env.development?

  # Uncomment this this line to customize the data sent with your Person objects.
  # Your custom procedure should return a Hash of attributes
  # config.person_builder = lambda {|user| {:keys => :values}}

  # Defaults to Rails.logger or Logger.new(STDOUT). Set to Logger.new('/dev/null') to disable logging.
  # config.logger = Logger.new('/dev/null')  
end