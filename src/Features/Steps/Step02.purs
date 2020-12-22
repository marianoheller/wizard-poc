module Features.Steps.Step02 where

import Prelude

import Data.Argonaut (JsonDecodeError)
import Data.Argonaut as Argo
import Data.Either (Either(..), note)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), isJust)
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Class.Console (error)
import Lumi.Components.Form (FormBuilder, Validated)
import Lumi.Components.Form as F
import Lumi.Components.Input as Input
import Lumi.Components.LabeledField (RequiredField(..))
import Lumi.Components.Select (SelectOption)
import Milkis as M
import Milkis.Impl.Window (windowFetch)
import React.Basic (JSX)
import React.Basic.DOM as D

fetch :: M.Fetch
fetch = M.fetch windowFetch

type SecondStepFormData
  = { country :: Validated (Maybe CountryOption)
    , workFromHome :: Boolean
    , height :: Validated String
    , favoriteColor :: Validated (Maybe String)
    }

type SecondStepResult
  = { country :: CountryOption
    , workFromHome :: Boolean
    , height :: Maybe Number
    , favoriteColor :: String
    }

type CountryOption
  = { name :: String
    , id :: String
    }

type CountryOptions
  = Array CountryOption

fetchOptions :: String -> Aff CountryOptions
fetchOptions input = do
  res <- map Argo.fromString $ M.text =<< fetch (M.URL $ "https://restcountries.eu/rest/v2/name/" <> input) M.defaultFetchOptions
  case (Argo.decodeJson res) :: Either JsonDecodeError CountryOptions of
    Right countries -> pure countries
    Left e -> do
      error $ show e
      pure []

toSelectOption :: CountryOption -> SelectOption
toSelectOption c = { value: c.name, label: c.name }

optionRenderer :: CountryOption -> JSX
optionRenderer c = D.text c.name

validateCountry :: Maybe CountryOption -> Either String CountryOption
validateCountry = note "lala"

secondStepForm :: forall props. Maybe Int -> FormBuilder { readonly :: Boolean | props } SecondStepFormData SecondStepResult
secondStepForm age = ado
  country <-
    F.indent "Country" Required
      $ F.focus (prop (SProxy :: SProxy "country"))
      $ F.validated validateCountry
      $ F.asyncSelect fetchOptions toSelectOption optionRenderer
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
  in { country, workFromHome, height, favoriteColor }
