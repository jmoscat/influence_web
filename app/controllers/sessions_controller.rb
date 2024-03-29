class SessionsController < ApplicationController
	def create
	  auth = request.env["omniauth.auth"]
	  user = User.where(:provider => auth['provider'], 
	                    :uid => auth['uid']).first || User.create_with_omniauth(auth)
	  session[:user_id] = user.id
	  user.fb_token = auth['credentials']['token']
	  influence = user.calculate_influence
	  message = influence.to_s + "%"
	  redirect_to root_url, :notice => influence.to_s
	end
	def new
	  redirect_to '/auth/facebook'
	end
	def destroy
	  reset_session
	  redirect_to root_url, notice => 'Signed out'
	end

end
