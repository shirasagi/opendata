class Uploader::Agents::Nodes::FileController < ApplicationController
  include Cms::NodeFilter::View

  public
    def index
      render nothing: true
    end
end
