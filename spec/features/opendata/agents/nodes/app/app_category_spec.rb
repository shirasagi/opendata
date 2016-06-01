require 'spec_helper'

describe "opendata_agents_nodes_app_category", dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:layout) { create_cms_layout }
  let(:node_category_folder) { create :cms_node_node, cur_site: site, layout_id: layout.id }
  let(:node_app) { create :opendata_node_app, cur_site: site, layout_id: layout.id }
  let(:node) do
    create(
      :opendata_node_app_category,
      cur_site: site,
      cur_node: node_app,
      layout_id: layout.id,
      name: "opendata_agents_nodes_app_category",
      filename: "#{node_category_folder.filename}",
      depth: node_app.depth + 1)
  end
  before do
    create(
      :opendata_node_category,
      cur_site: site,
      cur_node: node_category_folder,
      layout_id: layout.id,
      filename: "kurashi",
      depth: node_category_folder.depth + 1)
    create(:opendata_node_search_app, cur_site: site, cur_node: node_app, layout_id: layout.id)
  end

  let(:index_path) { "#{node.url}/kurashi" }
  let(:rss_path) { "#{node.url}/kurashi/rss.xml" }
  let(:nothing_path) { "#{node.url}index.html" }

  it "#index" do
    visit index_path
    expect(current_path).to eq index_path
  end

  it "#rss" do
    visit rss_path
    expect(current_path).to eq rss_path
  end

  it "#nothing" do
    visit nothing_path
    expect(current_path).to eq nothing_path
  end
end
