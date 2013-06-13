CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider                         => 'Google',
    :google_storage_access_key_id     => 'GOOGU6UU44VXBIGQYDBZ',
    :google_storage_secret_access_key => 'u/+BGy7+/07zNq5heaO/liDRiC86sIUdYTGTOJZ3'
  }
  config.fog_directory = 'luxhaven'
end