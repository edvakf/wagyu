(module
  (func (export "big_small_or_equal") (param $x i32) (param $y i32) (result i32)
    (if (result i32)
      (i32.gt_s (get_local $x) (get_local $y)) ;; condition
      (then
        i32.const 1
      )
      (else
        (if (result i32)
          (i32.lt_s (get_local $x) (get_local $y)) ;; condition
          (then
            i32.const 2
          )
          (else
            i32.const 3
          )
        )
      )
    )
  )
)

;; wat2wasm -v big_small_or_equal.wat
;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 02                                        ; num params
;; 000000d: 7f                                        ; i32
;; 000000e: 7f                                        ; i32
;; 000000f: 01                                        ; num results
;; 0000010: 7f                                        ; i32
;; 0000009: 07                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000011: 03                                        ; section code
;; 0000012: 00                                        ; section size (guess)
;; 0000013: 01                                        ; num functions
;; 0000014: 00                                        ; function 0 signature index
;; 0000012: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000015: 07                                        ; section code
;; 0000016: 00                                        ; section size (guess)
;; 0000017: 01                                        ; num exports
;; 0000018: 12                                        ; string length
;; 0000019: 6269 675f 736d 616c 6c5f 6f72 5f65 7175  big_small_or_equ
;; 0000029: 616c                                     al  ; export name
;; 000002b: 00                                        ; export kind
;; 000002c: 00                                        ; export func index
;; 0000016: 16                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000002d: 0a                                        ; section code
;; 000002e: 00                                        ; section size (guess)
;; 000002f: 01                                        ; num functions
;; ; function body 0
;; 0000030: 00                                        ; func body size (guess)
;; 0000031: 00                                        ; local decl count
;; 0000032: 20                                        ; local.get
;; 0000033: 00                                        ; local index
;; 0000034: 20                                        ; local.get
;; 0000035: 01                                        ; local index
;; 0000036: 4a                                        ; i32.gt_s
;; 0000037: 04                                        ; if
;; 0000038: 7f                                        ; i32
;; 0000039: 41                                        ; i32.const
;; 000003a: 01                                        ; i32 literal
;; 000003b: 05                                        ; else
;; 000003c: 20                                        ; local.get
;; 000003d: 00                                        ; local index
;; 000003e: 20                                        ; local.get
;; 000003f: 01                                        ; local index
;; 0000040: 48                                        ; i32.lt_s
;; 0000041: 04                                        ; if
;; 0000042: 7f                                        ; i32
;; 0000043: 41                                        ; i32.const
;; 0000044: 02                                        ; i32 literal
;; 0000045: 05                                        ; else
;; 0000046: 41                                        ; i32.const
;; 0000047: 03                                        ; i32 literal
;; 0000048: 0b                                        ; end
;; 0000049: 0b                                        ; end
;; 000004a: 0b                                        ; end
;; 0000030: 1a                                        ; FIXUP func body size
;; 000002e: 1c                                        ; FIXUP section size
