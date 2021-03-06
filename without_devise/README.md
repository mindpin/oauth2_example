# without_devise
这个 rails 工程里演示了 weibo qq github 的 oauth2 认证，基于 omniauth，没有使用 devise

如果你想在自己的工程增加 weibo qq github 的 oauth2 认证，就在自己工程增加以下内容即可

## 引用 gem
```ruby
gem "mongoid", "4.0.0"
gem "omniauth-weibo-oauth2"
gem "omniauth-qq"
gem "omniauth-github"
gem "figaro"
```

## omniauth 配置
```ruby
# config/initializers/omniauth.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :weibo, ENV['WEIBO_KEY'], ENV['WEIBO_SECRET']
  provider :qq_connect, ENV['QQ_CONNECT_KEY'], ENV['QQ_CONNECT_SECRET']
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

OmniAuth.config.logger = Rails.logger
```

## application 配置
```yml
# config/application.yml

WEIBO_KEY: xxx
WEIBO_SECRET: xxx
QQ_CONNECT_KEY: xxx
QQ_CONNECT_SECRET: xxx
GITHUB_KEY: xxx
GITHUB_SECRET: xxx
```

## routes
```ruby
  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/sign_out', to: 'sessions#destroy'
```

## model
```ruby
# user.rb
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  has_many :user_tokens
end
```

```ruby
# user_token.rb
class UserToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :provider,   type: String
  field :uid,        type: String
  field :token,      type: String
  field :expires_at, type: String
  field :expires,    type: Boolean

  belongs_to :user
end
```

## helper
```ruby
# app/helpers/application_helper.rb

module ApplicationHelper
  def current_user=(user)
    user_id = user.id.to_s
    cookies.permanent.signed["user_id"] = user_id
  end

  def current_user
    user_id = cookies.signed["user_id"]
    User.where(:id => user_id).last
  end

  def user_signed_in?
    !!current_user
  end

  def user_sign_out!
    cookies.delete "user_id"
  end
end
```

## controller
```ruby
# application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include helper
  include ApplicationHelper
end
```

```ruby
# sessions_controller.rb
class SessionsController < ApplicationController

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
```
