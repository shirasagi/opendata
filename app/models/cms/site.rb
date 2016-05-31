class Cms::Site
  include SS::Model::Site
  include Cms::SitePermission
  include Cms::Addon::PageSetting
  include Opendata::Addon::SiteSetting

  set_permission_name "cms_sites"
end
