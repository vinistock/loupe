# frozen_string_literal: true

module Guava
  # Color
  #
  # This class is responsible for coloring
  # strings.
  class Color
    # @return [Hash<Symbol, String>]
    COLORS = {
      red: "31",
      green: "32",
      yellow: "33"
    }.freeze

    # @param enabled [Boolean]
    def initialize(enabled)
      @enabled = enabled
    end

    # @param string [String, Symbol]
    # @param color [Symbol]
    # @return [String]
    def p(string, color)
      return string unless @enabled

      color_code = COLORS[color]
      "\033[1;#{color_code}m#{string}\033[0m"
    end
  end
end
