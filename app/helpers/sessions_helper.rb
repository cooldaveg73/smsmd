module SessionsHelper

  def get_project_and_set_subtitle
    return nil if session[:project_id].nil?
    project = Project.find_by_id(session[:project_id])
    @subtitle = "#{project.name} Project"
    return project
  end

end
