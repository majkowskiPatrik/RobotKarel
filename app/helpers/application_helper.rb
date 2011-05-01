module ApplicationHelper
  def show_flashes

    if !flash[:notice].nil?
      value = content_tag(:div, flash[:notice], :class=>"flash_notice")
    end

    if !flash[:warning].nil?
      value = content_tag(:div, flash[:warning], :class=>"flash_warning")
    end

    if !flash[:error].nil?
      value = content_tag(:div, flash[:error], :class=>"flash_error")
    end

    return value

  end
  
end
