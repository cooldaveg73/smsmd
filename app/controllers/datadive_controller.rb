class DatadiveController < ApplicationController
  def overview
    @project = get_project_and_set_subtitle
    @title = "DataDive (SF 2011)"
  end
end
