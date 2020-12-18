module App.Wizard where

import Prelude
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), isJust, maybe)
import Data.String.NonEmpty (toString) as NES
import Data.Symbol (SProxy(..))
import Lumi.Components.Form (FormBuilder, Validated)
import Lumi.Components.Form as F
import Lumi.Components.Input as Input
import Lumi.Components.LabeledField (RequiredField(..))
import Lumi.Components.Text as T
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

-- First step
type FirstStepFormData
  = { firstName :: Validated String
    , lastName :: Validated String
    , age :: Validated String
    }

type FirstStepResult
  = { firstName :: String
    , lastName :: String
    , age :: Maybe Int
    }

firstStepForm :: forall props. FormBuilder { readonly :: Boolean | props } FirstStepFormData FirstStepResult
firstStepForm = ado
  firstName <-
    F.indent "First name" Required
      $ F.focus (prop (SProxy :: SProxy "firstName"))
      $ F.validated (F.nonEmpty "First name")
      $ F.textbox
  lastName <-
    F.indent "Last name" Required
      $ F.focus (prop (SProxy :: SProxy "lastName"))
      $ F.validated (F.nonEmpty "Last name")
      $ F.textbox
  age <-
    F.indent "Age" Neither
      $ F.focus (prop (SProxy :: SProxy "age"))
      $ F.validated (F.optional (F.validInt "Age"))
      $ F.number
          { min: Just 0.0
          , max: Nothing
          , step: Input.Step 1.0
          }
  in { firstName: NES.toString firstName, lastName: NES.toString lastName, age }

-- Second step
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

-- Third step
type ThirdStepFormData
  = { hasAdditionalInfo :: Boolean
    , additionalInfo :: Validated String
    }

type ThirdStepResult
  = { hasAdditionalInfo :: Boolean
    , additionalInfo :: Maybe String
    }

thirdStepForm ::
  forall props.
  FirstStepResult ->
  SecondStepResult ->
  FormBuilder { readonly :: Boolean | props } ThirdStepFormData ThirdStepResult
thirdStepForm { firstName, lastName, age } { country, workFromHome, height, favoriteColor } =
  F.parallel "thirdStepForm" do
    F.sequential "text"
      $ F.static
      $ T.p_
      $ "Alright! What I know so far is that your name is "
      <> firstName
      <> " "
      <> lastName
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
    hasAdditionalInfo <-
      F.sequential "hasAdditionalInfo"
        $ F.indent "Do you want to give me additional information?" Neither
        $ F.focus (prop (SProxy :: SProxy "hasAdditionalInfo"))
        $ F.switch
    additionalInfo <-
      F.sequential "additionalInfo"
        $ if not hasAdditionalInfo then
            pure Nothing
          else
            F.indent "Additional information" Required
              $ F.focus (prop (SProxy :: SProxy "additionalInfo"))
              $ map (Just <<< NES.toString)
              $ F.validated (F.nonEmpty "Additional info")
              $ F.textarea
    pure { hasAdditionalInfo, additionalInfo }
