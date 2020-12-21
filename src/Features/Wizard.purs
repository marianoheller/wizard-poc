module Features.Wizard where

import Prelude

import Features.Steps.Step01 (FirstStepFormData, firstStepForm)
import Features.Steps.Step02 (SecondStepFormData, secondStepForm)
import Features.Steps.Step03 (ThirdStepFormData, thirdStepForm)
import Data.Lens.Record (prop)
import Data.Maybe (maybe)
import Data.Symbol (SProxy(..))
import Lumi.Components.Form as F
import Lumi.Components.Wizard (Wizard)
import Lumi.Components.Wizard as W

data Step
  = FirstStep
  | SecondStep
  | ThirdStep

derive instance eqStep :: Eq Step

type FormData
  = { firstStep :: FirstStepFormData
    , secondStep :: SecondStepFormData
    , thirdStep :: ThirdStepFormData
    }

type Result
  = { text :: String
    , occupation :: String
    }

exampleWizard :: Wizard Step { readonly :: Boolean } FormData Result
exampleWizard = do
  firstStep <-
    W.step FirstStep
      $ F.focus (prop (SProxy :: SProxy "firstStep"))
      $ firstStepForm
  secondStep <-
    W.step SecondStep
      $ F.focus (prop (SProxy :: SProxy "secondStep"))
      $ secondStepForm firstStep.age
  thirdStep <-
    W.step ThirdStep
      $ F.focus (prop (SProxy :: SProxy "thirdStep"))
      $ thirdStepForm firstStep secondStep
  let
    { firstName, lastName, age } = firstStep
  let
    { country, workFromHome, height, favoriteColor } = secondStep
  pure
    { text:
        "I know now that your name is " <> firstName <> " " <> lastName
          <> maybe "" (\a -> ", you are " <> show a <> " years old") age
          <> ", live in "
          <> country
          <> " and "
          <> (if workFromHome then "do" else "do not")
          <> " work from home."
          <> " Also, "
          <> maybe "" (\h -> " you are " <> show h <> " inches tall, and ") height
          <> " your favorite color is "
          <> favoriteColor
          <> "."
    , occupation: "PureScript programmer"
    }
