{ name = "wizard-poc"
, dependencies = [ "console", "effect", "psci-support", "lumi-components" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
