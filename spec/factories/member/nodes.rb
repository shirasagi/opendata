FactoryGirl.define do
  factory :member_node_login, class: Member::Node::Login, traits: [:cms_node] do
    cur_site { cms_site }
    route "member/login"
    filename { SS.config.oauth.prefix_path.sub(/^\//, '') || "auth" }
    twitter_oauth "enabled"
    twitter_client_id { "#{unique_id}" }
    twitter_client_secret { "#{unique_id}" }
    facebook_oauth "enabled"
    facebook_client_id { "#{unique_id}" }
    facebook_client_secret { "#{unique_id}" }
  end
end
