module Features.Steps.Step02 where

import Prelude
import Data.Argonaut as Argo
import Data.Bifunctor (lmap)
import Data.Either (Either(..), note)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), isJust)
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
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
  = { country :: String
    , workFromHome :: Boolean
    , height :: Maybe Number
    , favoriteColor :: String
    }

type CountryOption
  = { name :: String }

type CountrySearchPayload
  = Array CountryOption

fetchOptions :: String -> Aff CountrySearchPayload
fetchOptions input = do
  res <- map Argo.jsonParser $ M.text =<< fetch (M.URL $ "https://restcountries.eu/rest/v2/name/" <> input) M.defaultFetchOptions
  case (res >>= (lmap show <<< Argo.decodeJson)) :: Either String CountrySearchPayload of
    Right countries -> pure countries
    Left e -> pure []

toSelectOption :: CountryOption -> SelectOption
toSelectOption c = { value: c.name, label: c.name }

optionRenderer :: CountryOption -> JSX
optionRenderer c = D.text c.name

validateCountry :: Maybe CountryOption -> Either String CountryOption
validateCountry = note "Search and select a country"

secondStepForm :: forall props. Maybe Int -> FormBuilder { readonly :: Boolean | props } SecondStepFormData SecondStepResult
secondStepForm age = ado
  country <-
    map _.name
      $ F.indent "Country" Required
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
