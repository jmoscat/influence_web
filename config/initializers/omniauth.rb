Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '337447679708646', '6a2e9afc580b2a35c17e500b6a0c6a77',
  {:scope => 'email,user_hometown,user_likes,user_location,user_status,read_stream,status_update',
  	:client_options => {:ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'}}}
end