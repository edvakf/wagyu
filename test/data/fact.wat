(module
  (func $fact (export "fact") (param $n i64) (result i64)
    (if (result i64)
      (i64.eq (get_local $n) (i64.const 0)) ;; condition
      (then
        i64.const 1
      )
      (else
        (i64.mul
          (get_local $n)
          (call $fact
            (i64.sub (get_local $n) (i64.const 1))
          )
        )
      )
    )
  )
)

;; wat2wasm -v fact.wat
;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 01                                        ; num params
;; 000000d: 7e                                        ; i64
;; 000000e: 01                                        ; num results
;; 000000f: 7e                                        ; i64
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
;; 0000017: 04                                        ; string length
;; 0000018: 6661 6374                                fact  ; export name
;; 000001c: 00                                        ; export kind
;; 000001d: 00                                        ; export func index
;; 0000015: 08                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000001e: 0a                                        ; section code
;; 000001f: 00                                        ; section size (guess)
;; 0000020: 01                                        ; num functions
;; ; function body 0
;; 0000021: 00                                        ; func body size (guess)
;; 0000022: 00                                        ; local decl count
;; 0000023: 20                                        ; get_local
;; 0000024: 00                                        ; local index
;; 0000025: 42                                        ; i64.const
;; 0000026: 00                                        ; i64 literal
;; 0000027: 51                                        ; i64.eq
;; 0000028: 04                                        ; if
;; 0000029: 7e                                        ; i64
;; 000002a: 42                                        ; i64.const
;; 000002b: 01                                        ; i64 literal
;; 000002c: 05                                        ; else
;; 000002d: 20                                        ; get_local
;; 000002e: 00                                        ; local index
;; 000002f: 20                                        ; get_local
;; 0000030: 00                                        ; local index
;; 0000031: 42                                        ; i64.const
;; 0000032: 01                                        ; i64 literal
;; 0000033: 7d                                        ; i64.sub
;; 0000034: 10                                        ; call
;; 0000035: 00                                        ; function index
;; 0000036: 7e                                        ; i64.mul
;; 0000037: 0b                                        ; end
;; 0000038: 0b                                        ; end
;; 0000021: 17                                        ; FIXUP func body size
;; 000001f: 19                                        ; FIXUP section size
