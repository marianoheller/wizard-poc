module Features.Steps.Step01 where

import Prelude
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..))
import Data.String.NonEmpty (toString) as NES
import Data.Symbol (SProxy(..))
import Lumi.Components.Form (FormBuilder, Validated)
import Lumi.Components.Form as F
import Lumi.Components.Input as Input
import Lumi.Components.LabeledField (RequiredField(..))

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
