class AuthenticationController < ApplicationController
  before_action :authorize_request, except: :login

  def login
    if user&.authenticate(params[:password])
      render json: { token: token, exp: token_expiration,
                     username: user.username }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  private

  def user
    User.find_by_email(email)
  end

  def email
    params[:email]
  end

  def token
    Jwt.encode(user_id: user.id)
  end

  def token_expiration
    (Time.now + 24.hours.to_i).strftime("%m-%d-%Y %H:%M")
  end

  def login_params
    params.permit(:email, :password)
  end
end
