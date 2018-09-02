(module
  (func (export "switch") (param $i i32) (result i32)
    block $a
      block $b
        block $c
          get_local $i
          br_table $a $b $c
        end
        i32.const 333
        return
      end
      i32.const 222
      return
    end
    i32.const 111)
)

;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 01                                        ; num params
;; 000000d: 7f                                        ; i32
;; 000000e: 01                                        ; num results
;; 000000f: 7f                                        ; i32
;; 0000009: 06                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000010: 03                                        ; section code
;; 0000011: 00                                        ; section size (guess)
;; 0000012: 01                                        ; num functions
;; 0000013: 00                                        ; function 0 signature index
;; 0000011: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000014: 07                                        ; section code
;; 0000015: 00                                        ; section size (guess)
;; 0000016: 01                                        ; num exports
;; 0000017: 06                                        ; string length
;; 0000018: 7377 6974 6368                           switch  ; export name
;; 000001e: 00                                        ; export kind
;; 000001f: 00                                        ; export func index
;; 0000015: 0a                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000020: 0a                                        ; section code
;; 0000021: 00                                        ; section size (guess)
;; 0000022: 01                                        ; num functions
;; ; function body 0
;; 0000023: 00                                        ; func body size (guess)
;; 0000024: 00                                        ; local decl count
;; 0000025: 02                                        ; block
;; 0000026: 40                                        ; void
;; 0000027: 02                                        ; block
;; 0000028: 40                                        ; void
;; 0000029: 02                                        ; block
;; 000002a: 40                                        ; void
;; 000002b: 20                                        ; get_local
;; 000002c: 00                                        ; local index
;; 000002d: 0e                                        ; br_table
;; 000002e: 02                                        ; num targets
;; 000002f: 02                                        ; break depth
;; 0000030: 01                                        ; break depth
;; 0000031: 00                                        ; break depth for default
;; 0000032: 0b                                        ; end
;; 0000033: 41                                        ; i32.const
;; 0000034: cd02                                      ; i32 literal
;; 0000036: 0f                                        ; return
;; 0000037: 0b                                        ; end
;; 0000038: 41                                        ; i32.const
;; 0000039: de01                                      ; i32 literal
;; 000003b: 0f                                        ; return
;; 000003c: 0b                                        ; end
;; 000003d: 41                                        ; i32.const
;; 000003e: ef00                                      ; i32 literal
;; 0000040: 0b                                        ; end
;; 0000023: 1d                                        ; FIXUP func body size
;; 0000021: 1f                                        ; FIXUP section size
