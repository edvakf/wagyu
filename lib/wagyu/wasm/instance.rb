module Wagyu::Wasm
  class Instance
    attr_reader :exports

    # mod: Module
    def initialize(mod)
      @exports = mod.module_class.new()
    end
  end
end
