module ApplicationHelper
  def current_page? page
    page.downcase.strip === request.path_parameters[:controller]
  end
end
