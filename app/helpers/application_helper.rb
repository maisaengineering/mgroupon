module ApplicationHelper

  def flash_class(level)
    case level
      when :notice then "flash-alert alert-notice"
      when :success then "flash-alert alert-success"
      when :error then "flash-alert alert-error"
      when :warning then "flash-alert alert-warning"
    end
  end

end
