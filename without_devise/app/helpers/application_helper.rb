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
