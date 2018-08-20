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
