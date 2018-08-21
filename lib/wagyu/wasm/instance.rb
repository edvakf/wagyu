module Wagyu::Wasm
  class Instance
    attr_reader :exports

    # mod: Module
    def initialize(mod, import_object)
      @exports = mod.module_class.new(import_object)
    end
  end
end
