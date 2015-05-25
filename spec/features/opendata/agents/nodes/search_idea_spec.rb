require 'spec_helper'

describe "opendata_search_ideas", dbscope: :example do
  let(:site) { cms_site }
  let(:node) { create_once :opendata_node_search_idea, name: "opendata_search_ideas" }

  let(:index_path) { "#{node.url}index.html" }
  let(:rss_path) { "#{node.url}rss.xml" }

  context "search_idea" do
    it "#index" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit index_path
        expect(current_path).to eq index_path
      end
    end

    it "#index released" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit "#{index_path}?&sort=released"
        expect(current_path).to eq index_path
      end
    end

    it "#index popular" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit "#{index_path}?&sort=popular"
        expect(current_path).to eq index_path
      end
    end

    it "#index attention" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit "#{index_path}?&sort=attention"
        expect(current_path).to eq index_path
      end
    end

    it "#keyword_input" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit index_path
        fill_in "s_keyword", with: "アイデア"
        click_button "検索"

        expect(status_code).to eq 200
      end
    end

    it "#category_select" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit index_path
        # select "くらし", from: "s_category_id"
        select "", from: "s_category_id"
        click_button "検索"

        expect(status_code).to eq 200
      end
    end

    it "#area_select" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit index_path
        # select "徳島県", from: "s_area_id"
        select "", from: "s_area_id"
        click_button "検索"

        expect(status_code).to eq 200
      end
    end

    it "#tag_input" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", index_path)
        visit index_path
        fill_in "s_tag", with: "テスト"
        click_button "検索"

        expect(status_code).to eq 200
      end
    end

    it "#rss" do
      page.driver.browser.with_session("public") do |session|
        session.env("HTTP_X_FORWARDED_HOST", site.domain)
        session.env("REQUEST_PATH", rss_path)
        visit rss_path
        expect(current_path).to eq rss_path
      end
    end
  end
end
