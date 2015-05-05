-- A Demonstration of Agda
--
-- Alan Jeffrey <ajeffrey@bell-labs.com>
--
-- Agda is:
-- * a foundation of mathematics
-- * a programming language
--
-- Foundationally:
-- * Constructive logic
-- * Dependent type theory
-- * Category theory
--
-- Pragmatically:
-- * User-defined static analysis
-- * IDE as "worlds geekiest video game"
-- * Back ends to Haskell, C and JavaScript
--
-- Trying to find a sweet spot between:
-- * Dynamically typed languages (e.g. JS) 
--   where correctness is unit tests
-- * Statically typed languages (e.g. Java)
--   where you're stuck with one static type system.
-- 
-- Dependently typed languages provide a sliding scale:
-- * unit tests with fixed data
-- * unit tests with randomized data
-- * unit tests with directed randomized data
-- * unit tests with exhaustive coverage
--   (another name for mathematical theorems)
--
-- Outline:
-- * Introduction
-- * Core Haskell-like language
-- * Dependent types for custom static analysis
--
-- Documentation: http://wiki.portal.chalmers.se/agda
-- Installation: sudo apt-get install agda agda-bin agda-mode
-- This file: https://gist.github.com/2004772
 
module Demo where
 
-- A type for booleans
 
data Bool : Set where
  true : Bool
  false : Bool
 
-- Emacs Agda-mode cheat sheet:
-- C-C C-L (load file)
-- C-C C-N (evaluate an expression)
-- C-C C-D (type of an expression)
-- C-C C-F (forward to next goal)
-- C-C C-B (back to previous goal)
-- C-C C-T (type of current goal)
-- C-C C-R (refine current goal)
-- C-C C-C (case split current goal)
-- Unicode entered in pseudo-\LaTeX
 
-- Negation and conjunction of booleans
 
¬ : Bool → Bool
¬ x = {!!}
 
_∧_ : Bool → Bool → Bool
x ∧ y = {!!}
 
-- A type for natural numbers
 
data ℕ : Set where
  zero : ℕ
  suc : ℕ → ℕ
 
-- Magic to write 3 rather than suc (suc (suc zero))
 
{-# BUILTIN NATURAL ℕ    #-}
 
-- Addition, equality and strict order of naturals
 
_+_ : ℕ → ℕ → ℕ
x + y = {!!}
 
_==_ : ℕ → ℕ → Bool
x == y = {!!}
 
_<_ : ℕ → ℕ → Bool
x < zero = false
zero < suc x = true
suc x < suc y = x < y
 
-- Lists
 
data List (A : Set) : Set where
  [] : List A
  _::_ : A → List A → List A
 
infixr 5 _::_
 
-- Concatenation of lists
 
_++_ : ∀ {A} → List A → List A → List A
xs ++ ys = {!!}
 
-- Custom static analysis: lists of a given length
 
data List# (A : Set) : ℕ → Set where
  [] : List# A {!!}
  _:::_ : ∀ {n} → A → List# A {!!} → List# A {!!}
 
infixr 5 _:::_
 
-- Concatenation of lists respects length
-- (Note, we can cut-and-paste the code!)
 
_+++_ : ∀ {A m n} → List# A m → List# A n → List# A (m + n)
xs +++ ys = {!!}
 
-- Type for unit tests
-- ok has type [ b ] whenever b evaluates to true
 
data [_] : Bool → Set where
  ok : [ true ]
 
-- Example unit tests
 
test₁ : [ ¬ (1 < 1) ]
test₁ = {!!}
 
test₂ : [ ¬ (2 < 2) ]
test₂ = {!!}
 
test₃ : [ ¬ (3 < 3) ]
test₃ = {!!}
 
-- Example exhaustive test
 
<asym : ∀ x → [ ¬ (x < x) ]
<asym x = {!!}
 
-- Example of the use of custom static analysis
-- Indexing of lists (requires a Maybe type)
 
data Maybe (A : Set) : Set where
  just : A → Maybe A
  nothing : Maybe A
 
_==?_ : Maybe ℕ → Maybe ℕ → Bool
nothing ==? nothing = true
nothing ==? just y  = false
just x  ==? just y  = x == y
just x  ==? nothing = false
 
index? : ∀ {A} → List A → ℕ → Maybe A
index? xs n = {!!}
 
-- Unit tests
 
test₄ : [ index? (3 :: 5 :: 7 :: 9 :: []) 2 ==? just 7 ]
test₄ = {!!}
 
test₅ : [ index? (3 :: 5 :: 7 :: 9 :: []) 5 ==? nothing ]
test₅ = {!!}
 
-- Indexing of sized lists (no Maybe type!)
 
index : ∀ {A m} → List# A m → ∀ n → [ n < m ] → A
index xs n n<m = {!!}
 
-- Unit tests
 
test₆ : [ index (3 ::: 5 ::: 7 ::: 9 ::: []) 2 ok == 7 ]
test₆ = {!!}
 
-- doesn't-typecheck : [ index (3 ::: 5 ::: 7 ::: 9 ::: []) 5 ok == 13 ]
-- doesn't-typecheck = ok
