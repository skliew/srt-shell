module SRT
  class Line
    def to_s(time_str_function=:time_str)
      [sequence, (display_coordinates ? send(time_str_function) + display_coordinates : send(time_str_function)), text, ''].flatten.join("\n")
    end
  end
end
