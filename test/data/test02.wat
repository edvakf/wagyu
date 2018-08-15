;; br_if with a return value
(module
  (func (export "test") (result i32)
    (block $block (result i32)
      i32.const 1
      (br_if $block (i32.eqz (i32.const 0)))
    )
  )
)

;; wat2wasm -v test02.wat
;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 00                                        ; num params
;; 000000d: 01                                        ; num results
;; 000000e: 7f                                        ; i32
;; 0000009: 05                                        ; FIXUP section size
;; ; section "Function" (3)
;; 000000f: 03                                        ; section code
;; 0000010: 00                                        ; section size (guess)
;; 0000011: 01                                        ; num functions
;; 0000012: 00                                        ; function 0 signature index
;; 0000010: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000013: 07                                        ; section code
;; 0000014: 00                                        ; section size (guess)
;; 0000015: 01                                        ; num exports
;; 0000016: 04                                        ; string length
;; 0000017: 7465 7374                                test  ; export name
;; 000001b: 00                                        ; export kind
;; 000001c: 00                                        ; export func index
;; 0000014: 08                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000001d: 0a                                        ; section code
;; 000001e: 00                                        ; section size (guess)
;; 000001f: 01                                        ; num functions
;; ; function body 0
;; 0000020: 00                                        ; func body size (guess)
;; 0000021: 00                                        ; local decl count
;; 0000022: 02                                        ; block
;; 0000023: 7f                                        ; i32
;; 0000024: 41                                        ; i32.const
;; 0000025: 01                                        ; i32 literal
;; 0000026: 41                                        ; i32.const
;; 0000027: 00                                        ; i32 literal
;; 0000028: 45                                        ; i32.eqz
;; 0000029: 0d                                        ; br_if
;; 000002a: 00                                        ; break depth
;; 000002b: 0b                                        ; end
;; 000002c: 0b                                        ; end
;; 0000020: 0c                                        ; FIXUP func body size
;; 000001e: 0e                                        ; FIXUP section size
