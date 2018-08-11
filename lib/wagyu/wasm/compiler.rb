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

      pp rep

      mod = Class.new do |c|
        define_method(:add) {|a, b| a+b }

        # if rep.export_section
        #   rep.export_section.exports.each_with_index do |export_entry, i|
        #     if export_entry.kind == :function
        #       c.define_method(export_entry.field) do |*args|
        #         stack = []
        #         args[0] + args[1]
        #       end
        #     end
        #   end
        # end
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
