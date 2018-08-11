module Wagyu::Wasm
  # usage:
  # mod = Module.new(binary) or Wasm.compile(binary)
  # Wasm.instantiate(mod, import_object)
  class Module
    def initialize(binary)
      io = StringIO.new(binary)
      Compiler.new(io).compile
    end
  end
end
