(module
  (func (export "test") (result i32)
    (local $n i32)
    (set_local $n (i32.const 5))

    (loop $loop (result i32)
      get_local $n

      (set_local $n (i32.sub (get_local $n) (i32.const 1)))

      (br_if $loop (i32.ne (get_local $n) (i32.const 0)))
    )
  )
)

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
;; 0000021: 01                                        ; local decl count
;; 0000022: 01                                        ; local type count
;; 0000023: 7f                                        ; i32
;; 0000024: 41                                        ; i32.const
;; 0000025: 05                                        ; i32 literal
;; 0000026: 21                                        ; set_local
;; 0000027: 00                                        ; local index
;; 0000028: 03                                        ; loop
;; 0000029: 7f                                        ; i32
;; 000002a: 20                                        ; get_local
;; 000002b: 00                                        ; local index
;; 000002c: 20                                        ; get_local
;; 000002d: 00                                        ; local index
;; 000002e: 41                                        ; i32.const
;; 000002f: 01                                        ; i32 literal
;; 0000030: 6b                                        ; i32.sub
;; 0000031: 21                                        ; set_local
;; 0000032: 00                                        ; local index
;; 0000033: 20                                        ; get_local
;; 0000034: 00                                        ; local index
;; 0000035: 41                                        ; i32.const
;; 0000036: 00                                        ; i32 literal
;; 0000037: 47                                        ; i32.ne
;; 0000038: 0d                                        ; br_if
;; 0000039: 00                                        ; break depth
;; 000003a: 0b                                        ; end
;; 000003b: 0b                                        ; end
;; 0000020: 1b                                        ; FIXUP func body size
;; 000001e: 1d                                        ; FIXUP section size
