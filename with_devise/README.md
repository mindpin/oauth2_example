# with_devise
这个 rails 工程里演示了 weibo qq github 的 oauth2 认证，基于 devise and omniauth

如果你想在自己的工程增加 weibo qq github 的 oauth2 认证，就在自己工程增加以下内容即可

## 引用 gem
```ruby
gem "mongoid", "4.0.0"
gem "figaro"
gem 'devise'
gem "omniauth-weibo-oauth2"
gem "omniauth-qq"
gem "omniauth-github"
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

## devise 配置
命令行运行
```
rails generate devise:install

rails generate devise user
```

## omniauth 配置
```
# config/initializers/devise.rb

config.omniauth :weibo, ENV['WEIBO_KEY'], ENV['WEIBO_SECRET']
config.omniauth :qq_connect, ENV['QQ_CONNECT_KEY'], ENV['QQ_CONNECT_SECRET']
config.omniauth :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']  
```


## routes
```ruby
# config/routes.rb

devise_for :users, 
  :path => "",
  :controllers => { :omniauth_callbacks => "omniauth_callbacks" }  
```

## model
```ruby
# user.rb
# 增加如下内容
  ######################### issues/3626 ###########################
  # https://github.com/mongoid/mongoid/issues/3626#issuecomment-64700154
  def self.serialize_from_session(key, salt)
    (key = key.first) if key.kind_of? Array
    (key = BSON::ObjectId.from_string(key['$oid'])) if key.kind_of? Hash

    record = to_adapter.get(key)
    record if record && record.authenticatable_salt == salt
  end

  def self.serialize_into_session(record)
    [record.id.to_s, record.authenticatable_salt]
  end
  ######################### issues/3626 ###########################
  has_many :user_tokens
  field :name, type: String

  def password_required?
    false
  end

  def email_required?
    false
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

## controller
```ruby
# omniauth_callbacks_controller.rb

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def weibo
    _create_for_omniauth
  end

  def qq_connect
    _create_for_omniauth
  end

  def github
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

      user = User.create!(:name => auth_hash["info"]["nickname"])
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

    # 处理微博登陆逻辑
    render :json => {
      :user        => user_token.user,
      :user_token  => user_token
    }
  end
end
```


## 登陆

## weibo
访问 http://localhost:3000/auth/weibo
## qq
yourhost.com 是在本地 host 文件配置的对应本地IP的一个域名（因为QQ应用不支持IP回调地址）
访问 http://yourhost.com:3000/auth/qq_connect
## github
访问 http://localhost:3000/auth/github