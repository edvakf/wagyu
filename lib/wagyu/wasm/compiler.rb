require "iseq_builder"
require "wagyu/wasm/parser"
require "pp"

module Wagyu::Wasm
  class Compiler
    def initialize
    end

    # return Module
    def compile(io)
      rep = Parser.new(io).parse

      # pp rep

      mod = Class.new do |c|
        if rep.function_section
          rep.function_section.types.each_with_index do |type_idx, func_idx|
            function_body = rep.code_section.bodies[func_idx]
            params = rep.type_section.types[type_idx].params.map.with_index{|type, i| "_local_#{i}_#{type}"}

            locals = params # TODO: add function_body.locals
            var_num = 0 # number of temporary variables

            stack = []
            code = ""

            function_body.code.each do |op|
              case op[:op]
              when :get_local
                stack << locals[op[:local_index]]
              when :add
                var = "_var_#{var_num}_#{op[:type]}"
                code += "#{var} = #{stack.pop} + #{stack.pop}\n"
                stack << var
                var_num += 1
              when :mul
                var = "_var_#{var_num}_#{op[:type]}"
                code += "#{var} = #{stack.pop} * #{stack.pop}\n"
                stack << var
                var_num += 1
              when :end
                code += stack.pop
              end
            end

            # p stack # should assert stack is empty??

            eval(<<~EVAL, binding)
              def __#{func_idx}(#{params.join(", ")})
                #{code}
              end
            EVAL
          end
        end

        if rep.export_section
          rep.export_section.exports.each_with_index do |export_entry, i|
            if export_entry.kind == :function
              alias_method export_entry.field.to_sym, "__#{export_entry.index}".to_sym
            end
          end
        end
      end

      mod
    end

    # include ISeqBuilder
    #
    # def initialize
    # end
    #
    # # return Module
    # def compile(wasm_binary)
    #   @mod = Parser.new(wasm_binary).parse
    #   to_iseq
    # end
    #
    # def to_iseq
    #   return if @mod.code_section.nil? # TODO: what should be returned?
    #
    #   builder = ISeqBuilder.builder
    #
    #   @mod.code_section.bodies.each do |function_body|
    #     locals = function_body[:locals]
    #     code = function_body[:code]
    #     # p code
    #
    #     builder.top_level do
    #       # code.each do |op|
    #       #   p op
    #       # end
    #       putself
    #       putstring string("Hello world")
    #       opt_send_without_block callinfo(:puts, 1, FCALL | ARGS_SIMPLE), 0
    #       leave
    #     end
    #   end
    #
    #   # p builder
    #   # builder.to_bin
    #   builder.to_iseq
    # end
  end
end
