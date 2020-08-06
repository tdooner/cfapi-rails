module ApplicationHelper
  def nav_link_item(text, path)
    content_tag('li', class: ['nav-item', ('active' if current_page?(path))]) do
      link_to(path, class: 'nav-link') do
        text
      end
    end
  end
end
