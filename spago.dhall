{ name = "wizard-poc"
, dependencies =
  [ "argonaut"
  , "console"
  , "effect"
  , "lumi-components"
  , "milkis"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
