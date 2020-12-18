-- let upstream =
--       https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200127/packages.dhall sha256:06a623f48c49ea1c7675fdf47f81ddb02ae274558e29f511efae1df99ea92fb8

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20201021/packages.dhall sha256:55ebdbda1bd6ede4d5307fbc1ef19988c80271b4225d833c8d6fb9b6fb1aa6d8

let overrides = {=}

let additions =
  { lumi-components =
      { dependencies =
          [ "aff-coroutines"
          , "aff"
          , "arrays"
          , "avar"
          , "console"
          , "coroutines"
          , "fixed-precision"
          , "foldable-traversable"
          , "foreign-object"
          , "generics-rep"
          , "foreign"
          , "gen"
          , "integers"
          , "maybe"
          , "nullable"
          , "numbers"
          , "prelude"
          , "profunctor-lenses"
          , "random"
          , "react-basic"
          , "react-basic-dom"
          , "react-basic-emotion"
          , "react-basic-hooks"
          , "react-basic-classic"
          , "react-basic-compat"
          , "react-dnd-basic"
          , "record"
          , "simple-json"
          , "strings"
          , "tuples"
          , "unsafe-reference"
          , "web-html"
          , "web-storage"
          , "validation"
          , "js-timers"
          , "heterogeneous"
          , "free"
          , "colors"
          , "web-uievents"
          ]
      , repo =
          "https://github.com/lumihq/purescript-lumi-components"
      , version =
          "v14.0.0"
      }
  , fixed-precision =
      { dependencies =
          [ "integers"
          , "maybe"
          , "bigints"
          , "strings"
          , "math"
          ]
      , repo =
          "https://github.com/lumihq/purescript-fixed-precision"
      , version =
          "v4.3.1"
      }
  , react-basic-emotion =
      { dependencies =
          [ "colors"
          , "foreign"
          , "numbers"
          , "prelude"
          , "react-basic"
          , "typelevel-prelude"
          , "unsafe-reference"
          , "maybe"
          , "bigints"
          , "strings"
          , "math"
          ]
      , repo =
          "https://github.com/lumihq/purescript-react-basic-emotion"
      , version =
          "v5.0.0"
      }
  , react-dnd-basic =
      { dependencies =
          [ "prelude"
          , "react-basic"
          , "nullable"
          , "promises"
          ]
      , repo =
          "https://github.com/lumihq/purescript-react-dnd-basic"
      , version =
          "v7.0.0"
      }
  }

in  upstream // overrides // additions