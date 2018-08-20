;; br_if with a return value
(module
  (func (export "test") (result i32)
    (block $block (result i32)
      i32.const 1
      (br_if $block (i32.eqz (i32.const 0)))
    )
  )
)
