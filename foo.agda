

module Foo where
  data bool : Set where
    false : bool
    true : bool

  f : bool → bool → bool
  f p q = p
  g : bool → bool
  g x = x

  id : bool → bool
<<<<<<< HEAD
  id x = {!x!}

-- fsjidogofd
-- fsdgds
=======
  id x = {!0: bool!}
>>>>>>> origin/master
