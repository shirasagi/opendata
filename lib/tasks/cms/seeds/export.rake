namespace :cms do

  def find_layout(site, layout)
    ret = Cms::Layout.site(site).where(_id: layout).first
    ret ||= Cms::Layout.site(site).where(filename: layout).first
    ret ||= Cms::Layout.site(site).where(name: layout).first
    ret
  end

  def find_page(site, page)
    ret = Cms::Page.site(site).where(_id: page).first
    ret ||= Cms::Page.site(site).where(filename: page).first
    ret ||= Cms::Page.site(site).where(name: page).first
    ret = ret.becomes_with_route if ret.present?
    ret
  end

  namespace :seeds do
    task :export_layouts => :environment do
      site = SS::Site.where(host: ENV['site']).first
      next unless site

      output_dir = ENV["output"] || 'layouts'
      ::FileUtils.mkdir_p(output_dir) unless ::Dir.exist?(output_dir)

      Cms::Layout.site(site).each do |layout|
        filename = "#{output_dir}/#{layout.filename}"
        dirname = ::File.dirname(filename)
        ::FileUtils.mkdir_p(dirname) unless ::Dir.exist?(dirname)

        open(filename, "w") do |f|
          f.write layout.html.gsub("\r\n", "\n")
        end

        puts "save_layout filename: \"#{layout.filename}\", name: \"#{layout.name}\""
      end
    end

    task :export_parts => :environment do
      site = SS::Site.where(host: ENV['site']).first
      next unless site

      output_dir = ENV["output"] || 'parts'
      ::FileUtils.mkdir_p(output_dir) unless ::Dir.exist?(output_dir)

      Cms::Part.site(site).each do |part|
        part = part.becomes_with_route || part

        filename = "#{output_dir}/#{part.filename}"
        dirname = ::File.dirname(filename)
        ::FileUtils.mkdir_p(dirname) unless ::Dir.exist?(dirname)

        html = part.html rescue nil
        if html.present? && html.is_a?(String)
          open(filename, "w") do |f|
            f.write html.gsub("\r\n", "\n")
          end
        end

        upper_html = part.upper_html rescue nil
        if upper_html.present? && upper_html.is_a?(String)
          open(filename.sub(/\.html$/, ".upper_html"), "w") do |f|
            f.write upper_html.gsub("\r\n", "\n")
          end
        end

        loop_html = part.loop_html rescue nil
        if loop_html.present? && loop_html.is_a?(String)
          open(filename.sub(/\.html$/, ".loop_html"), "w") do |f|
            f.write loop_html.gsub("\r\n", "\n")
          end
        end

        lower_html = part.lower_html rescue nil
        if lower_html.present? && lower_html.is_a?(String)
          open(filename.sub(/\.html$/, ".lower_html"), "w") do |f|
            f.write lower_html.gsub("\r\n", "\n")
          end
        end

        message = "save_part filename: \"#{part.filename}\", name: \"#{part.name}\", route: \"#{part.route}\""
        message << ", ajax_view: \"enabled\"" if part.ajax_view.present? && part.ajax_view == 'enabled'
        message << ", conditions: %w(#{part.conditions.join(' ')})" if part.try(:conditions).present?
        message << ", limit: #{part.limit}" if part.try(:limit).present?
        message << ", sort: \"#{part.sort}\"" if part.try(:sort).present?
        puts message
      end
    end

    task :export_page => :environment do
      site = SS::Site.where(host: ENV['site']).first
      next unless site

      page = find_page(site, ENV['page'])
      next unless page

      output_dir = ENV["output"] || 'pages'
      ::FileUtils.mkdir_p(output_dir) unless ::Dir.exist?(output_dir)

      filename = "#{output_dir}/#{page.filename}"
      dirname = ::File.dirname(filename)
      ::FileUtils.mkdir_p(dirname) unless ::Dir.exist?(dirname)

      html = page.try(:html)
      if html.present?
        open(filename, "w") do |f|
          f.write html.gsub("\r\n", "\n")
        end
      end

      summary_html = page.try(:summary_html)
      if summary_html.present?
        open(filename.sub(/\.html$/, "") + ".summary_html", "w") do |f|
          f.write summary_html.gsub("\r\n", "\n")
        end
      end

      message = "save_page route: \"#{page.route}\""
      message << ", filename: \"#{page.filename}\""
      message << ", name: \"#{page.name}\""
      message << ", layout_id: layouts[\"#{page.layout.filename.sub(/\..*$/, '')}\"].id"
      puts message
    end
  end
end
