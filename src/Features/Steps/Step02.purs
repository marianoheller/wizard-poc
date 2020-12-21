module Features.Steps.Step02 where

import Prelude
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), isJust)
import Data.String.NonEmpty (toString) as NES
import Data.Symbol (SProxy(..))
import Lumi.Components.Form (FormBuilder, Validated)
import Lumi.Components.Form as F
import Lumi.Components.Input as Input
import Lumi.Components.LabeledField (RequiredField(..))

type SecondStepFormData
  = { country :: Validated String
    , workFromHome :: Boolean
    , height :: Validated String
    , favoriteColor :: Validated (Maybe String)
    }

type SecondStepResult
  = { country :: String
    , workFromHome :: Boolean
    , height :: Maybe Number
    , favoriteColor :: String
    }

secondStepForm :: forall props. Maybe Int -> FormBuilder { readonly :: Boolean | props } SecondStepFormData SecondStepResult
secondStepForm age = ado
  country <-
    F.indent "Country" Required
      $ F.focus (prop (SProxy :: SProxy "country"))
      $ F.validated (F.nonEmpty "Country")
      $ F.textbox
  workFromHome <-
    if isJust age && age < Just 15 then
      pure false
    else
      F.indent "Work from home?" Neither
        $ F.focus (prop (SProxy :: SProxy "workFromHome"))
        $ F.switch
  height <-
    F.indent "Height (in)" Optional
      $ F.focus (prop (SProxy :: SProxy "height"))
      $ F.validated (F.optional (F.validNumber "Height"))
      $ F.number { min: Just 0.0, max: Nothing, step: Input.Any }
  favoriteColor <-
    F.indent "Favorite color" Required
      $ F.focus (prop (SProxy :: SProxy "favoriteColor"))
      $ F.validated (F.nonNull "Favorite color")
      $ F.select identity pure
          [ { label: "Red", value: "red" }
          , { label: "Green", value: "green" }
          , { label: "Blue", value: "blue" }
          ]
  in { country: NES.toString country, workFromHome, height, favoriteColor }

