class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  protected

    def page_number(page)
      if page == current_page
        link(page, page, :class => "active")
      else
        link(page, page)
      end
    end
    
    def previous_or_next_page(page, text, classname)
      if page
        link(text, page)
      end
    end

    # wrapper for the pagination container.
    def html_container(html)
      # .paggination.right
      tag(:div, html, :class => "paggination right")
    end

end