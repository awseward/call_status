let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/nonempty/runs-on/package.dhall
        sha256:d6326ac83c4c31d5b04769b148374950f6814864450d1bc3f56bee21b43eb969

let Plural =
    -- TODO: Pull this up to dhall-utils if it seems to be useful
    -- Like `NonEmpty`, but instead of representing `> 0`, it represents `> 1`
      let NonEmpty =
          -- TODO: Take from Prelude instead when possible
            dhall-misc.GHA.NonEmpty

      let Plural = λ(a : Type) → { head : a, neck : a, tail : List a }

      let make =
            λ(a : Type) →
            λ(head : a) →
            λ(neck : a) →
            λ(tail : List a) →
              { head, neck, tail }

      let _testMake =
              assert
            :   make Text "foo" "bar" [ "baz", "moop" ]
              ≡ { head = "foo", neck = "bar", tail = [ "baz", "moop" ] }

      let pair =
            λ(a : Type) →
            λ(head : a) →
            λ(neck : a) →
              make a head neck ([] : List a)

      let _testPair =
              assert
            :   pair Text "foo" "bar"
              ≡ { head = "foo", neck = "bar", tail = [] : List Text }

      let toList
          : ∀(a : Type) → Plural a → List a
          = λ(a : Type) → λ(xs : Plural a) → [ xs.head, xs.neck ] # xs.tail

      let _testToList =
              assert
            :   toList Text (make Text "foo" "bar" [ "baz", "moop" ])
              ≡ [ "foo", "bar", "baz", "moop" ]

      let toNonEmpty
          : ∀(a : Type) → Plural a → NonEmpty.Type a
          = λ(a : Type) →
            λ(xs : Plural a) →
              NonEmpty.make a xs.head ([ xs.neck ] # xs.tail)

      let _testToNonEmpty =
              assert
            :   toNonEmpty Text (make Text "foo" "bar" [ "baz" ])
              ≡ NonEmpty.make Text "foo" [ "bar", "baz" ]

      in  { Type = Plural, make, pair, toList, toNonEmpty }

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ { Plural }
