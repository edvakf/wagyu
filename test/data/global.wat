(module
  (global $j (import "env" "initial") i32)
  (global $i (mut i32) (i32.const 0))
  (func $start
    (set_global $i (get_global $j))
  )
  (func $counter (result i32)
    (set_global $i (i32.add (get_global $i) (i32.const 1)))
    get_global $i
  )
  (start $start)
  (export "counter" (func $counter))
)

;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 02                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 00                                        ; num params
;; 000000d: 00                                        ; num results
;; ; type 1
;; 000000e: 60                                        ; func
;; 000000f: 00                                        ; num params
;; 0000010: 01                                        ; num results
;; 0000011: 7f                                        ; i32
;; 0000009: 08                                        ; FIXUP section size
;; ; section "Import" (2)
;; 0000012: 02                                        ; section code
;; 0000013: 00                                        ; section size (guess)
;; 0000014: 01                                        ; num imports
;; ; import header 0
;; 0000015: 03                                        ; string length
;; 0000016: 656e 76                                  env  ; import module name
;; 0000019: 07                                        ; string length
;; 000001a: 696e 6974 6961 6c                        initial  ; import field name
;; 0000021: 03                                        ; import kind
;; 0000022: 7f                                        ; i32
;; 0000023: 00                                        ; global mutability
;; 0000013: 10                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000024: 03                                        ; section code
;; 0000025: 00                                        ; section size (guess)
;; 0000026: 02                                        ; num functions
;; 0000027: 00                                        ; function 0 signature index
;; 0000028: 01                                        ; function 1 signature index
;; 0000025: 03                                        ; FIXUP section size
;; ; section "Global" (6)
;; 0000029: 06                                        ; section code
;; 000002a: 00                                        ; section size (guess)
;; 000002b: 01                                        ; num globals
;; 000002c: 7f                                        ; i32
;; 000002d: 01                                        ; global mutability
;; 000002e: 41                                        ; i32.const
;; 000002f: 00                                        ; i32 literal
;; 0000030: 0b                                        ; end
;; 000002a: 06                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000031: 07                                        ; section code
;; 0000032: 00                                        ; section size (guess)
;; 0000033: 01                                        ; num exports
;; 0000034: 07                                        ; string length
;; 0000035: 636f 756e 7465 72                        counter  ; export name
;; 000003c: 00                                        ; export kind
;; 000003d: 01                                        ; export func index
;; 0000032: 0b                                        ; FIXUP section size
;; ; section "Start" (8)
;; 000003e: 08                                        ; section code
;; 000003f: 00                                        ; section size (guess)
;; 0000040: 00                                        ; start func index
;; 000003f: 01                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000041: 0a                                        ; section code
;; 0000042: 00                                        ; section size (guess)
;; 0000043: 02                                        ; num functions
;; ; function body 0
;; 0000044: 00                                        ; func body size (guess)
;; 0000045: 00                                        ; local decl count
;; 0000046: 23                                        ; get_global
;; 0000047: 00                                        ; global index
;; 0000048: 24                                        ; set_global
;; 0000049: 01                                        ; global index
;; 000004a: 0b                                        ; end
;; 0000044: 06                                        ; FIXUP func body size
;; ; function body 1
;; 000004b: 00                                        ; func body size (guess)
;; 000004c: 00                                        ; local decl count
;; 000004d: 23                                        ; get_global
;; 000004e: 01                                        ; global index
;; 000004f: 41                                        ; i32.const
;; 0000050: 01                                        ; i32 literal
;; 0000051: 6a                                        ; i32.add
;; 0000052: 24                                        ; set_global
;; 0000053: 01                                        ; global index
;; 0000054: 23                                        ; get_global
;; 0000055: 01                                        ; global index
;; 0000056: 0b                                        ; end
;; 000004b: 0b                                        ; FIXUP func body size
;; 0000042: 14                                        ; FIXUP section size
