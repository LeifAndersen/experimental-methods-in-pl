(import (rnrs)
        (larceny compiler))

(compiler-switches 'fast-unsafe)
(compile-file "bubble.sch")
(compile-file "struct-bm.sch")
