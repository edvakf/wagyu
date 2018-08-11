require "wagyu/wasm/compiler"

# Wagyu::Wasm is intended to be used in a similar manner to the WebAssembly JS API
module Wagyu::Wasm
  class << self
    # return Instance
    def instantiate(binary, import_object: nil)
      instantiate_streaming(StringIO.new(binary))
    end

    # return Instance
    def instantiate_streaming(io, import_object: nil)
      compile_streaming(io).eval # TODO: evalじゃない
    end

    # return Module
    def compile(binary)
      compile_streaming(StringIO.new(binary))
    end

    # return Module
    def compile_streaming(io)
      Compiler.new.compile(io)
    end
  end
end
