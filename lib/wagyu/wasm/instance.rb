module Wagyu::Wasm
  class Instance
    attr_reader :exports

    # mod: Module
    def initialize(mod, import_object)
      mod.new(import_object)
    end
  end
end
