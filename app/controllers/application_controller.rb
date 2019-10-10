class ApplicationController < ActionController::API
  before_action :allow_profiler_in_envs

  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      @decoded = Jwt.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  private

   def allow_profiler_in_envs
    if Rails.env.qa? || Rails.env.development?
      Rack::MiniProfiler.authorize_request
    end
  end
end
