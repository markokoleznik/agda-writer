module Foo where
  data bool : Set where
    false : bool
    true : bool

  f : bool → bool → bool
  f p q = ?

  g : bool → bool
  g x = x

  id : bool → bool
  id x = x

  neg : bool → bool
  neg x = ?

  test : bool → bool
  test x = ?