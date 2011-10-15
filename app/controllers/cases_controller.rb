class CasesController < ApplicationController

  def report
    project = get_project_and_set_subtitle
    current_page = params[:page].to_i
    per_page_count = 100
    pages = get_pages( current_page, per_page_count, project.messages.count )
    @prev_page, @next_page = pages
    begin_index = current_page * per_page_count
    @messages = project.messages.order("id DESC").offset(begin_index).limit(per_page_count)
    @timezone = +5.5
    @title = "Messages Summary"
    render :layout => "sortable_table"
  end

  def cases
    kase = Case.find_by_id(params[:id].to_i)
    redirect_to( root_path ) if kase.nil?
    authorize_project(kase.project)
    @messages = kase.messages.order("id DESC")
    @timezone = +5.5
    @title = "Case #{kase.id} Summary"
    @subtitle = [ kase.project.name, "Project" ].join(" ")
    render :layout => "sortable_table"
  end

  def main
    project = get_project_and_set_subtitle
    authorize_project(project)
    current_page = params[:page].to_i
    per_page_count = 15
    pages = get_pages( current_page, per_page_count, project.cases.count )
    @prev_page, @next_page = pages
    begin_index = current_page * per_page_count
    @cases = project.cases.order("id DESC").offset(begin_index).limit(per_page_count)
    @title = "Cases Summary"
  end

  def mark_fake
    kase = Case.find_by_id(params[:case][:id])
    kase.update_attributes( :fake => !kase.fake )
    head :ok
  end

end
