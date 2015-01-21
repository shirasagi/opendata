class Opendata::Agents::Nodes::IdeaController < ApplicationController
  include Cms::NodeFilter::View
  include Opendata::UrlHelper
  include Opendata::MypageFilter
  include Opendata::IdeaFilter

  before_action :set_idea, only: [:show_point, :add_point, :point_members]
  before_action :set_idea_comment, only: [:show_comment, :add_comment]
  skip_filter :logged_in?

  private
    def set_idea
      @idea_path = @cur_path.sub(/\/point\/.*/, ".html")

      @idea = Opendata::Idea.site(@cur_site).public.
        filename(@idea_path).
        first

      raise "404" unless @idea
    end

    def set_idea_comment
      @idea_comment_path = @cur_path.sub(/\/comment\/.*/, ".html")

      @idea_comment = Opendata::Idea.site(@cur_site).public.
        filename(@idea_comment_path).
        first

      cond = { site_id: @cur_site.id, idea_id: @idea_comment.id }
      @comments = Opendata::IdeaComment.where(cond)

      @comment_mode = logged_in?(redirect: false)

      raise "404" unless @idea_comment
    end

  public
    def pages
      Opendata::Idea.site(@cur_site).public
    end

    def index
      @count          = pages.size
      @node_url       = "#{@cur_node.url}"
      @search_url     = search_ideas_path + "?"
      @rss_url        = search_ideas_path + "rss.xml?"
      @items          = pages.order_by(released: -1).limit(10)
      @point_items    = pages.order_by(point: -1).limit(10)
      @download_items = pages.order_by(downloaded: -1).limit(10)

      @tabs = [
        { name: "新着順", url: "#{@search_url}&sort=released", pages: @items, rss: "#{@rss_url}&sort=released" },
        { name: "人気順", url: "#{@search_url}&sort=popular", pages: @point_items, rss: "#{@rss_url}&sort=popular" },
        { name: "注目順", url: "#{@search_url}&sort=attention", pages: @download_items, rss: "#{@rss_url}&sort=attention" }
        ]

      max = 50
      @areas    = aggregate_areas
      @tags     = aggregate_tags(max)

      respond_to do |format|
        format.html { render }
        format.rss  { render_rss @cur_node, @items }
        end
    end

    def show_point
      @cur_node.layout = nil
      @mode = nil

      if logged_in?(redirect: false)
        @mode = :add

        cond = { site_id: @cur_site.id, member_id: @cur_member.id, idea_id: @idea.id }
        @mode = :cancel if point = Opendata::IdeaPoint.where(cond).first
      end
    end

    def add_point
      @cur_node.layout = nil
      raise "403" unless logged_in?(redirect: false)

      cond = { site_id: @cur_site.id, member_id: @cur_member.id, idea_id: @idea.id }

      if point = Opendata::IdeaPoint.where(cond).first
        point.destroy
        @idea.inc point: -1
        @mode = :add
      else
        Opendata::IdeaPoint.new(cond).save
        @idea.inc point: 1
        @mode = :cancel
      end

      render :show_point
    end

    def point_members
      @cur_node.layout = nil
      @items = Opendata::IdeaPoint.where(site_id: @cur_site.id, idea_id: @idea.id)
    end

    def show_comment
      @cur_node.layout = nil
    end

    def add_comment
      @cur_node.layout = nil
      raise "403" unless logged_in?(redirect: false)

      cond = { site_id: @cur_site.id, member_id: @cur_member.id, idea_id: @idea_comment.id, text: "" }
      Opendata::IdeaComment.new(cond).save

      render :show_comment
    end

end
