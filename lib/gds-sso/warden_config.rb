require 'warden'
require 'omniauth/oauth'

Warden::Manager.serialize_into_session do |user|
  user.uid
end

Warden::Manager.serialize_from_session do |uid|
  GDS::SSO.user_klass.find_by_uid(uid)
end

Warden::Strategies.add(:signonotron) do
  def valid?
    true
  end

  def authenticate!
    if request.env['omniauth.auth'].nil?
      fail!("No credentials, bub") 
    else
      user = prep_user(request.env['omniauth.auth'])
      success!(user)
    end
  end

  private

  def prep_user(auth_hash)
    user = GDS::SSO.user_klass.find_for_gds_oauth(auth_hash)
    fail!("Couldn't process credentials") unless user
    user
  end
end
