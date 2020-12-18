module Main where

import Prelude
import App.Wizard (FormData, Step(..), Result, exampleWizard)
import Data.Either (Either(..), isRight)
import Data.Maybe (Maybe(..), isNothing, maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Effect.Uncurried (mkEffectFn1)
import Effect.Unsafe (unsafePerformEffect)
import Lumi.Components.Form as F
import Lumi.Components.Form.Defaults (formDefaults)
import Lumi.Components.Wizard (WizardStep)
import Lumi.Components.Wizard as W
import React.Basic.DOM (render)
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture, capture_)
import React.Basic.Hooks (Component, Reducer, component, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

data Action a
  = OnChange (FormData -> FormData)
  | SetModified
  | SetWizardStep (WizardStep Step { readonly :: Boolean } FormData Result)
  | Finalize Result

type AppState
  = { formData :: FormData
    , result :: Maybe Result
    , wizardStep :: WizardStep Step { readonly :: Boolean } FormData Result
    }

initialState :: AppState
initialState =
  { formData: formDefaults :: FormData
  , result: Nothing
  , wizardStep: W.liftStep exampleWizard
  }

reducer :: forall a. Reducer AppState (Action a)
reducer =
  unsafePerformEffect $ mkReducer
    $ \s a -> case a of
        OnChange modify -> s { formData = modify s.formData }
        SetModified -> case W.stepIdentifier s.wizardStep of
          Just FirstStep -> s { formData { firstStep = F.setModified s.formData.firstStep } }
          Just SecondStep -> s { formData { secondStep = F.setModified s.formData.secondStep } }
          Just ThirdStep -> s { formData { thirdStep = F.setModified s.formData.thirdStep } }
          Nothing -> s
        SetWizardStep wizardStep -> s { wizardStep = wizardStep }
        Finalize result -> s { result = Just result }

mkApp :: Component Unit
mkApp = do
  component "App" \props -> React.do
    state /\ dispatch <- useReducer initialState reducer
    pure
      $ R.div
          { style: R.css { alignSelf: "stretch" }
          , children:
              case state.result of
                Nothing ->
                  [ W.wizard
                      { step: state.wizardStep
                      , value: state.formData
                      , onChange: dispatch <<< OnChange
                      , forceTopLabels: false
                      , inlineTable: false
                      , formProps: { readonly: false }
                      }
                  , R.div
                      { style: R.css { justifyContent: "flex-end" }
                      , children:
                          let
                            previousStepM = W.previousStep state.wizardStep

                            nextStepM = W.resumeStep state.wizardStep { readonly: false } state.formData

                            hasFinalResult = maybe false isRight nextStepM
                          in
                            [ R.button
                                { title: "Back"
                                , disabled: if isNothing previousStepM then true else false
                                , onClick: maybe (mkEffectFn1 mempty) (capture identity <<< const <<< dispatch <<< SetWizardStep) previousStepM
                                }
                            , R.button
                                { title: if hasFinalResult then "Submit" else "Next"
                                , style: R.css { marginLeft: "12px" }
                                , onClick:
                                    capture_ case nextStepM of
                                      Nothing -> dispatch SetModified
                                      Just (Left nextStep) -> dispatch (SetWizardStep nextStep)
                                      Just (Right r) -> dispatch (Finalize r)
                                }
                            ]
                      }
                  ]
                Just { text, occupation } ->
                  [ R.p_ [ R.text "Dilly dily data, my magic's a done! I'm a Wizard, after all." ]
                  , R.p_ [ R.text text ]
                  , R.p_ [ R.text "From all this information, I can only conclude that yourself are." ]
                  ]
          }

main :: Effect Unit
main = do
  mContainer <- getElementById "root" =<< (toNonElementParentNode <$> (document =<< window))
  case mContainer of
    Nothing -> throw "Could not find body."
    Just container -> do
      app <- mkApp
      render (app unit) container
