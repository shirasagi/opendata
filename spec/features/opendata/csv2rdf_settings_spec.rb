require 'spec_helper'

describe "opendata_csv2rdf_settings", type: :feature, dbscope: :example do
  let(:site) { cms_site }
  let(:node) { create(:opendata_node_dataset) }
  let(:dataset) { create(:opendata_dataset, node: node) }
  let(:license_logo_path) { Rails.root.join("spec", "fixtures", "ss", "logo.png") }
  let(:license_logo_file) { Fs::UploadedFile.create_from_file(license_logo_path, basename: "spec") }
  let(:license) { create(:opendata_license, site: site, file: license_logo_file) }
  let(:content_type) { "application/vnd.ms-excel" }
  let(:csv_file) { Rails.root.join("spec", "fixtures", "opendata", "shift_jis.csv") }
  let!(:resource) { dataset.resources.new(attributes_for(:opendata_resource, license_id: license.id)) }
  let(:ipa_core_sample_file) { Rails.root.join("spec", "fixtures", "rdf", "ipa-core-sample.ttl") }

  before do
    Fs::UploadedFile.create_from_file(csv_file, basename: "spec") do |f|
      resource.in_file = f
      resource.save!
    end
    resource.reload
  end

  before do
    # To stabilize spec, csv2tdf convert job is executed in-place process .
    allow(SS::RakeRunner).to receive(:run_async).and_wrap_original do |_, *args|
      config = { name: "default", model: "job:service", num_workers: 0, poll: %w(default voice_synthesis) }
      config.stringify_keys!
      Job::Service.run config
    end
  end

  before do
    # overwrite config to disable fuseki
    @save_fuseki = SS.config.opendata.fuseki
    SS::Config.replace_value_at(:opendata, :fuseki, "disable" => true)
  end

  after do
    SS::Config.replace_value_at(:opendata, :fuseki, @save_fuseki)
  end

  before do
    Rdf::VocabImportJob.new.call(site.host, "ic", ipa_core_sample_file, Rdf::Vocab::OWNER_SYSTEM, 1000)
  end

  describe "convert csv to rdf" do
    let(:header_size_path) { opendata_dataset_resource_header_size_path site.host, node.id, dataset.id, resource.id }
    let(:rdf_class_path) { opendata_dataset_resource_rdf_class_path site.host, node.id, dataset.id, resource.id }
    let(:rdf_class_preview_path) { opendata_dataset_resource_rdf_class_preview_path site.host, node.id, dataset.id, resource.id }
    let(:column_types_path) { opendata_dataset_resource_column_types_path site.host, node.id, dataset.id, resource.id }
    # let(:rdf_prop_select_path) { opendata_dataset_resource_rdf_prop_select_path site.host, node.id, dataset.id, resource.id }
    let(:rdf_prop_select_path) do
      routes = Rails.application.routes.url_helpers
      url = routes.url_for host: "example.com", controller: "opendata/csv2rdf_settings", action: "rdf_prop_select", site: site.host, cid: node.id, dataset_id: dataset.id, resource_id: resource.id, column_index: 1
      url = ::URI.parse(url)
      url.path
    end
    let(:confirmation_path) { opendata_dataset_resource_confirmation_path site.host, node.id, dataset.id, resource.id }
    let(:show_resource_path) { opendata_dataset_resource_path site.host, node.id, dataset.id, resource.id }

    before { login_cms_user }
    it do
      expect(SS.config.opendata.fuseki["disable"]).to be_truthy

      visit header_size_path
      expect(status_code).to eq 200
      expect(current_path).to eq header_size_path

      within "form#item-form" do
        click_button I18n.t("opendata.button.next")
      end

      expect(status_code).to eq 200
      expect(current_path).to eq rdf_class_path

      # クラスのプレビュー画面に寄り道
      within "form#item-form" do
        click_link "ic:定期スケジュール型"
      end

      expect(status_code).to eq 200
      expect(current_path).to eq rdf_class_preview_path

      within "body" do
        click_link "戻る"
      end

      expect(status_code).to eq 200
      expect(current_path).to eq rdf_class_path

      rdf_class = Rdf::Class.first
      within "form#item-form" do
        choose "item_class_id_#{rdf_class.id}"
        click_button I18n.t("opendata.button.next")
      end

      expect(status_code).to eq 200
      expect(current_path).to eq column_types_path

      # "xsd:integer" を "xsd:decimal" に変更
      within "div.csv2rdf-settings-table-container" do
        click_link "xsd:integer"
      end

      expect(status_code).to eq 200
      expect(current_path).to eq rdf_prop_select_path

      within "form#item-form" do
        choose "item_prop_id_endemicdecimal"
        click_button "保存"
      end

      expect(status_code).to eq 200
      expect(current_path).to eq column_types_path

      within "form#item-form" do
        click_button I18n.t("opendata.button.next")
      end

      expect(status_code).to eq 200
      expect(current_path).to eq confirmation_path

      within "form#item-form" do
        click_button I18n.t("opendata.button.build")
      end

      expect(status_code).to eq 200
      expect(current_path).to eq show_resource_path

      # check for whether ttl file is created and registered.
      expect { dataset.reload }.to change { dataset.resources.size }.by(1)
      ttl_resource = dataset.resources.where(format: "TTL").first
      expect(ttl_resource).not_to be_nil
    end
  end
end
