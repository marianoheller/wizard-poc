module App.Slice where

import Prelude
import App.Wizard (FormData, Step(..), Result, exampleWizard)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import Lumi.Components.Form as F
import Lumi.Components.Form.Defaults (formDefaults)
import Lumi.Components.Wizard (WizardStep)
import Lumi.Components.Wizard as W
import React.Basic.Hooks (Reducer, mkReducer)

data Action
  = OnChange (FormData -> FormData)
  | SetModified
  | SetWizardStep (WizardStep Step { readonly :: Boolean } FormData Result)
  | Finalize Result

type AppState
  = { formData :: FormData
    , result :: Maybe Result
    , wizardStep :: WizardStep Step { readonly :: Boolean } FormData Result
    }

type AppDispatch
  = Action -> Effect Unit

initialState :: AppState
initialState =
  { formData: formDefaults :: FormData
  , result: Nothing
  , wizardStep: W.liftStep exampleWizard
  }

reducer' :: AppState -> Action -> AppState
reducer' s = case _ of
  OnChange modify -> s { formData = modify s.formData }
  SetModified -> case W.stepIdentifier s.wizardStep of
    Just FirstStep -> s { formData { firstStep = F.setModified s.formData.firstStep } }
    Just SecondStep -> s { formData { secondStep = F.setModified s.formData.secondStep } }
    Just ThirdStep -> s { formData { thirdStep = F.setModified s.formData.thirdStep } }
    Nothing -> s
  SetWizardStep wizardStep -> s { wizardStep = wizardStep }
  Finalize result -> s { result = Just result }

reducer :: Reducer AppState Action
reducer = unsafePerformEffect $ mkReducer reducer'
