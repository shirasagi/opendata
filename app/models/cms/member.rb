class Cms::Member
  include Cms::Member::Model

  class << self
    public
      def create_with_omniauth(auth, site)
        create!do |omniuser|
          omniuser.site_id = site.id
          omniuser.oauth_type = auth.provider
          omniuser.oauth_id = auth.uid
          omniuser.oauth_token = auth.credentials.token
          omniuser.name = auth.info.name
          omniuser.email = auth.info.email
          omniuser.password = nil
        end
      end
  end
end
