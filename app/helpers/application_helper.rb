module ApplicationHelper
  def lookup_exercies(_preset_id)
    exercise = nil
    EXERCISES.each do |ex|
      if ex["id"].to_i == _preset_id.to_i
        exercise = ex
      end
    end
    return exercise
  end
end
