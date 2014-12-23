# 说明
这个版本库包含 with_devise 和 without_devise 两个 rails 工程，

with_devise 是基于 devise 和 omniauth 实现的 weibo qq github 的 oauth2 认证

without_devise 是基于 omniauth 实现的 weibo qq github 的 oauth2 认证

运行工程首先需要申请 key secret

## 申请 key secret

### weibo
申请网站 http://open.weibo.com

创建 网站接入 类型应用（如果只是为了测试，任何类型的应用都可以，应用的设置界面都是一样的）

创建成功后，进入应用的 应用信息->高级信息 在 OAuth2.0 授权设置 设置 授权回调页
，比如在without_devise 这个演示中使用的授权回调页是 http://yourip:3000/auth/weibo/callback

### qq_connect
申请网站 http://connect.qq.com

创建 网站接入 类型应用（创建应用时要注意，一定要是QQ互联的页面下创建应用，因为腾讯很多平台，所以相互有一些关联，一不小心点了页面上某个链接就跳转到其他平台页面了，比如 腾讯开放平台，我们这里需要使用的是QQ互联平台的应用）

创建应用时，有一些麻烦，网站地址需要通过验证才能创建，验证的规则是在域名首页增加 meta

另一个问题是：回调地址填写域名就可以，不用填写具体 url，但是不能填写 ip， 所以如果本地开发的话需要修改本地 host 映射一个域名才能本地调试开发

### github
申请网站 https://github.com/settings/applications

点击 Register new application 创建应用

创建应用表单的 Application name，Homepage URL，Application description 随意填写

Authorization callback URL要填写具体的授权回调页 url，比如在without_devise 这个演示中使用的授权回调页是 http://yourip:3000/auth/weibo/callback

## 运行工程的准备工作
第一次运行，请执行以下命令
```
cd without_devise # 或者 with_devise，两个工程同理
bundle
cp config/application.yml.development config/application.yml
cp config/mongoid.yml.development mongoid.yml

```
然后打开 config/application.yml 配置相关 key secret

配置好后 ```rails s``` 启动项目

## 登陆

### weibo
访问 http://localhost:3000/auth/weibo

### qq_connect

yourhost.com 是在本地 host 文件配置的对应本地IP的一个域名（因为QQ应用不支持IP回调地址） 

以 windows 为例，打开 C:\Windows\System32\drivers\etc\hosts 文件，增加以下内容
```
127.0.0.1 yourhost.com
```

访问 http://yourhost.com:3000/auth/qq_connect

### github
访问 http://localhost:3000/auth/github

## 详细说明
详细的说明请看 with_devise 和 without_devise 目录下的 readme 文件