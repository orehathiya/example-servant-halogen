{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "pux-starter-app"
, dependencies = [ "console", "effect", "psci-support", "halogen", "affjax" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
