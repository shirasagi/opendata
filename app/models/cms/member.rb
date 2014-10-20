class Cms::Member
  include Cms::Member::Model

  class << self
    public
      def create_auth_member(auth, site)
        create! do |member|
          member.site_id = site.id
          member.oauth_type = auth.provider
          member.oauth_id = auth.uid
          member.oauth_token = auth.credentials.token
          member.name = auth.info.name
        end
      end
  end
end
