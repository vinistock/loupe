# frozen_string_literal: true

module Guava
  # Color
  #
  # This class is responsible for coloring
  # strings.
  class Color
    COLORS = {
      red: "31",
      green: "32",
      yellow: "33"
    }.freeze

    def initialize(enabled)
      @enabled = enabled
    end

    def p(string, color)
      return string unless @enabled

      color_code = COLORS[color]
      "\033[1;#{color_code}m#{string}\033[0m"
    end
  end
end
