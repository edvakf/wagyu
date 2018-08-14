;; given an integer n, return the sum of integers from 1 to n
(module
  (func (export "sum") (param $num i64) (result i64)
    (local $sum i64) ;; int sum
    (local $i i64) ;; int i

    (set_local $sum (i64.const 0)) ;; sum = 0
    (set_local $i (i64.const 1)) ;; i = 1

    ;; while(true)
    (block $block (loop $loop
      (br_if $block (i64.gt_u (get_local $i) (get_local $num))) ;; if (i >= num) break

      ;; inside loop
      (set_local $sum (i64.add (get_local $sum) (get_local $i))) ;; sum = sum + i

      (set_local $i (i64.add (get_local $i) (i64.const 1))) ;; i = i + 1
      (br $loop) ;; continue
    ))

    (get_local $sum)
  )
)

;; wat2wasm -v sum.wat
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
;; 0000017: 03                                        ; string length
;; 0000018: 7375 6d                                  sum  ; export name
;; 000001b: 00                                        ; export kind
;; 000001c: 00                                        ; export func index
;; 0000015: 07                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000001d: 0a                                        ; section code
;; 000001e: 00                                        ; section size (guess)
;; 000001f: 01                                        ; num functions
;; ; function body 0
;; 0000020: 00                                        ; func body size (guess)
;; 0000021: 01                                        ; local decl count
;; 0000022: 02                                        ; local type count
;; 0000023: 7e                                        ; i64
;; 0000024: 42                                        ; i64.const
;; 0000025: 00                                        ; i64 literal
;; 0000026: 21                                        ; set_local
;; 0000027: 01                                        ; local index
;; 0000028: 42                                        ; i64.const
;; 0000029: 01                                        ; i64 literal
;; 000002a: 21                                        ; set_local
;; 000002b: 02                                        ; local index
;; 000002c: 02                                        ; block
;; 000002d: 40                                        ; void
;; 000002e: 03                                        ; loop
;; 000002f: 40                                        ; void
;; 0000030: 20                                        ; get_local
;; 0000031: 02                                        ; local index
;; 0000032: 20                                        ; get_local
;; 0000033: 00                                        ; local index
;; 0000034: 56                                        ; i64.gt_u
;; 0000035: 0d                                        ; br_if
;; 0000036: 01                                        ; break depth
;; 0000037: 20                                        ; get_local
;; 0000038: 01                                        ; local index
;; 0000039: 20                                        ; get_local
;; 000003a: 02                                        ; local index
;; 000003b: 7c                                        ; i64.add
;; 000003c: 21                                        ; set_local
;; 000003d: 01                                        ; local index
;; 000003e: 20                                        ; get_local
;; 000003f: 02                                        ; local index
;; 0000040: 42                                        ; i64.const
;; 0000041: 01                                        ; i64 literal
;; 0000042: 7c                                        ; i64.add
;; 0000043: 21                                        ; set_local
;; 0000044: 02                                        ; local index
;; 0000045: 0c                                        ; br
;; 0000046: 00                                        ; break depth
;; 0000047: 0b                                        ; end
;; 0000048: 0b                                        ; end
;; 0000049: 20                                        ; get_local
;; 000004a: 01                                        ; local index
;; 000004b: 0b                                        ; end
;; 0000020: 2b                                        ; FIXUP func body size
;; 000001e: 2d                                        ; FIXUP section size
