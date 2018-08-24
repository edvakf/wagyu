module Wagyu::Wasm
  # instantiate this class through Wagyu::Wasm.compile
  class Module
    attr_reader :module_class

    def initialize
      @module_class = Class.new do
        def initialize(import_object)
          # TODO: fix form of import_object. temporarily asigning directly
          @import_object = import_object

          after_initialize
        end

        def _if(condition, then_proc, &else_block)
          if condition
            then_proc.call
          elsif else_block
            yield else_block
          else
            -1
          end
        end

        def _loop(&block)
          while true
            depth = yield block
            next if depth == 0
            return depth
          end
        end

        def _block(&block)
          yield block
        end
      end
    end
  end
end
