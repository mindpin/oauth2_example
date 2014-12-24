class SessionsController < ApplicationController
  def index
  end

  def create
    case params[:provider] 
    when "weibo"
      _create_for_weibo
    when "qq_connect"
      _create_for_qq_connect
    when "github"
      _create_for_github
    end
  end

  def _create_for_github
    _create_for_omniauth
  end

  def _create_for_weibo
    _create_for_omniauth
  end

  def _create_for_qq_connect
    _create_for_omniauth
  end

  def _create_for_omniauth
    auth_hash = request.env['omniauth.auth']
    uid = auth_hash["uid"]
    provider   = auth_hash["provider"]
    token      = auth_hash["credentials"]["token"]
    expires_at = auth_hash["credentials"]["expires_at"]
    expires    = auth_hash["credentials"]["expires"]
    
    user_token = UserToken.where(
      :uid      => uid,
      :provider => provider
    ).first

    if user_token.blank?
      user = User.create!(:name => auth_hash[:info][:nickname])
      user_token = user.user_tokens.create(
        :uid        => uid,
        :provider   => provider,
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    else
      user_token.update_attributes(
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    end
    self.current_user = user_token.user
    redirect_to "/"
  end

  def destroy
    self.user_sign_out!
    redirect_to "/"
  end
end