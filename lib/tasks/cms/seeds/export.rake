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
      ::Dir.mkdir(output_dir) unless ::Dir.exist?(output_dir)

      Cms::Layout.site(site).each do |layout|
        filename = "#{output_dir}/#{layout.filename}"
        dirname = ::File.dirname(filename)
        ::Dir.mkdir(dirname) unless ::Dir.exist?(dirname)

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
      ::Dir.mkdir(output_dir) unless ::Dir.exist?(output_dir)

      Cms::Part.site(site).each do |part|
        part = part.becomes_with_route || part

        filename = "#{output_dir}/#{part.filename}"
        dirname = ::File.dirname(filename)
        ::Dir.mkdir(dirname) unless ::Dir.exist?(dirname)

        if html = part.try(:html) && html.present?
          open(filename, "w") do |f|
            f.write html.gsub("\r\n", "\n")
          end
        end

        if upper_html = part.try(:upper_html) && upper_html.present?
          open(filename.sub(/\.html$/, ".upper_html"), "w") do |f|
            f.write upper_html.gsub("\r\n", "\n")
          end
        end

        if loop_html = part.try(:loop_html) && loop_html.present?
          open(filename.sub(/\.html$/, ".loop_html"), "w") do |f|
            f.write loop_html.gsub("\r\n", "\n")
          end
        end

        if lower_html = part.try(:lower_html) && lower_html.present?
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
      ::Dir.mkdir(output_dir) unless ::Dir.exist?(output_dir)

      filename = "#{output_dir}/#{page.filename}"
      dirname = ::File.dirname(filename)
      ::Dir.mkdir(dirname) unless ::Dir.exist?(dirname)

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
