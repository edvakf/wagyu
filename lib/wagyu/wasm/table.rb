module Wagyu::Wasm
  class Table
    def initialize(initial:, element:, maximum: nil)
      # TODO: assert element == 'anyfunc'
      @type = element
      @elements = Array.new(initial)
      @maximum = maximum
    end
  end
end
