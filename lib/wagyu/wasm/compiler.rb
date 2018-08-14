require "wagyu/wasm/parser"
require "pp"

module Wagyu::Wasm
  class MethodCompiler
    def initialize
      @var_num = 0
      @stack = []
      @code = []
    end

    def compile(function_index, function_body, types)
      params = types.params.map.with_index{|type, i| "local_#{i}"}

      locals = params # TODO: add function_body.locals

      @code << "def __#{function_index}(#{params.join(", ")})"

      function_body.code.each do |instr|
        case instr[:name]
        when :if
          add_instruction { "if #{@stack.pop}" }
        when :else
          @code << @stack.pop
          @code << "else"
        when :const
          add_instruction { instr[:value].to_s }
        when :eq
          add_instruction { "#{@stack.pop} == #{@stack.pop}" }
        when :get_local
          @stack << locals[instr[:local_index]]
        when :add
          add_instruction { "#{@stack.pop} + #{@stack.pop}" }
        when :sub
          add_instruction { a,b = @stack.pop(2); "#{a} - #{b}" }
        when :mul
          add_instruction { "#{@stack.pop} * #{@stack.pop}" }
        when :call
          add_instruction { "__#{instr[:function_index]}(#{@stack.pop})" }
        when :sqrt
          add_instruction { "Math.sqrt(#{@stack.pop})" }
        when :end
          @code << @stack.pop
          @code << "end"
        else
          raise StandardError.new("Unknown instruction: #{instr[:name]}")
        end
      end

      # p @stack # should assert stack is empty??
      # pp @code

      return @code.join("\n")
    end

    def add_instruction
      var = "var_#{@var_num}"
      @code << "#{var} = #{yield}"
      @stack << var
      @var_num += 1
    end
  end


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

            method = MethodCompiler.new.compile(
              func_idx,
              rep.code_section.bodies[func_idx],
              rep.type_section.types[type_idx]
            )

            # puts method
            eval(method)
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
  end
end
