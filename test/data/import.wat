(module
  (func $mul (import "util" "multiply") (param i32 i32) (result i32))
  (func $twice (param $a i32) (result i32)
    (call $mul (get_local $a) (i32.const 2))
  )
  (export "twice" (func $twice))
)

;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 02                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 02                                        ; num params
;; 000000d: 7f                                        ; i32
;; 000000e: 7f                                        ; i32
;; 000000f: 01                                        ; num results
;; 0000010: 7f                                        ; i32
;; ; type 1
;; 0000011: 60                                        ; func
;; 0000012: 01                                        ; num params
;; (module
;; 0000013: 7f                                        ; i32
;; 0000014: 01                                        ; num results
;; 0000015: 7f                                        ; i32
;; 0000009: 0c                                        ; FIXUP section size
;; ; section "Import" (2)
;; 0000016: 02                                        ; section code
;; 0000017: 00                                        ; section size (guess)
;; 0000018: 01                                        ; num imports
;; ; import header 0
;; 0000019: 04                                        ; string length
;; 000001a: 7574 696c                                util  ; import module name
;; 000001e: 08                                        ; string length
;; 000001f: 6d75 6c74 6970 6c79                      multiply  ; import field name
;; 0000027: 00                                        ; import kind
;; 0000028: 00                                        ; import signature index
;; 0000017: 11                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000029: 03                                        ; section code
;; 000002a: 00                                        ; section size (guess)
;; 000002b: 01                                        ; num functions
;; 000002c: 01                                        ; function 0 signature index
;; 000002a: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 000002d: 07                                        ; section code
;; 000002e: 00                                        ; section size (guess)
;; 000002f: 01                                        ; num exports
;; 0000030: 05                                        ; string length
;; 0000031: 7477 6963 65                             twice  ; export name
;; 0000036: 00                                        ; export kind
;; 0000037: 01                                        ; export func index
;; 000002e: 09                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000038: 0a                                        ; section code
;; 0000039: 00                                        ; section size (guess)
;; 000003a: 01                                        ; num functions
;; ; function body 0
;; 000003b: 00                                        ; func body size (guess)
;; 000003c: 00                                        ; local decl count
;; 000003d: 20                                        ; get_local
;; 000003e: 00                                        ; local index
;; 000003f: 41                                        ; i32.const
;; 0000040: 02                                        ; i32 literal
;; 0000041: 10                                        ; call
;; 0000042: 00                                        ; function index
;; 0000043: 0b                                        ; end
;; 000003b: 08                                        ; FIXUP func body size
;; 0000039: 0a                                        ; FIXUP section size
