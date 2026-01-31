module ApplicationHelper
  # Polish pluralization helper
  # Usage: polish_pluralize(count, "prezentacja", "prezentacje", "prezentacji")
  def polish_pluralize(count, one, few, many)
    return many if count == 0
    case count % 100
    when 1 then one
    when 2..4 then few
    else many
    end
  end
end
