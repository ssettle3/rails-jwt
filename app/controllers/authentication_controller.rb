class AuthenticationController < ApplicationController
  before_action :authorize_request, except: [:login, :sign_up]

  def login
    return render_missing_params if missing_login_params?

    if user.authenticate(params[:password])
      render json: { token: token, exp: token_expiration,
                     username: user.username }, status: :ok
    else
      render json: { error: 'Incorrect Password' }, status: :unauthorized
    end
  end

  def sign_up
    return render_missing_params if missing_signup_params?
    return render_password_mismatch if password_mismatch?

    user = create_user!
    render json: { username: user.username, token: token }, status: 201
  end

  private

  def user
    User.find_by(username: username)
  end

  def username
    params[:username]
  end

  def create_user!
    User.create!(sign_up_params)
  end

  def token
    Jwt.encode(user_id: user.id)
  end

  def token_expiration
    (Time.now + 24.hours.to_i).strftime("%m-%d-%Y %H:%M")
  end

  def sign_up_params
    params.permit(:username, :password, :password_confirmation)
  end

  def password_mismatch?
    params[:password] != params[:password_confirmation]
  end

  def missing_signup_params?
    !params.has_key?(:username) ||
    !params.has_key?(:password) ||
    !params.has_key?(:password_confirmation)
  end

  def missing_login_params?
    !params.has_key?(:username) ||
    !params.has_key?(:password)
  end

  def render_missing_params
    render json: { error: "username and password must be present"}, status: :unprocessable_entity
  end

  def render_password_mismatch
    render json: { error: "passords must match" }, status: :unprocessable_entity
  end

  def render_username_taken
    render json: {error: "username has been taken"}, status: :unprocessable_entity
  end
end
