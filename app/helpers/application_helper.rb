module ApplicationHelper

  def get_pages(current_page, per_page_count, total)
    if (current_page * per_page_count) > total
      next_page = current_page
    else
      next_page = current_page + 1
    end
    if current_page <= 0
      prev_page = 0
    else
      prev_page = current_page - 1
    end
    return prev_page, next_page
  end

end
