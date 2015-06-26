class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # default : `protect_from_forgery with: :exception`

  # TODO : If things won't work, comment out the line below
  # protect_from_forgery with: :null_session

  # Authenticate token every request
  before_action :authenticate_user_from_token!

  respond_to :json

  ##
  # User Authentication
  # # Authenticates the user iwth Oath2 resource woner password credentials
  def authenticate_user_from_token!
    auth_token = request.headers['Authorization']

    if auth_token
      authenticate_with_auth_token auth_token
    else
      authentication_error
    end

  end

  private

  def authenticate_with_auth_token(auth_token)

    unless auth_token.include?(':')
      authentication_error
      return
    end

    user_id = auth_token.split(':').first
    user = User.where(id: user_id).first

    if user && Devuse.secure_compare(user.access_token, auth_token )
      # User can access
      sign_in user, store: false
    else
      authentication_error
    end

  end

  ##
  # Authentication Error
  # Renders a 401 error
  def authentication_error
    render json: {error: t('unauthorized')}, status: 401  # Authentication timeout
  end


end
