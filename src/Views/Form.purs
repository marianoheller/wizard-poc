module Views.Form where

import Prelude
import Features.Slice (Action(..), AppState, AppDispatch)
import Data.Either (Either(..), isRight)
import Data.Maybe (Maybe(..), isNothing, maybe)
import Data.Tuple (Tuple)
import Effect.Uncurried (mkEffectFn1)
import Lumi.Components.Wizard as W
import React.Basic.DOM as R
import React.Basic.DOM.Events (capture, capture_)
import React.Basic.Hooks (Component, component, (/\))

mkFormView :: Component (Tuple AppState AppDispatch)
mkFormView = do
  component "FormView" \(state /\ dispatch) -> React.do
    pure
      $ R.div
          { style: R.css { alignSelf: "stretch" }
          , children:
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

                        nextText = if hasFinalResult then "Submit" else "Next"
                      in
                        [ R.button
                            { title: "Back"
                            , children: [ R.text "Back" ]
                            , disabled: if isNothing previousStepM then true else false
                            , onClick: maybe (mkEffectFn1 mempty) (capture identity <<< const <<< dispatch <<< SetWizardStep) previousStepM
                            }
                        , R.button
                            { title: nextText
                            , style: R.css { marginLeft: "12px" }
                            , onClick:
                                capture_ case nextStepM of
                                  Nothing -> dispatch SetModified
                                  Just (Left nextStep) -> dispatch (SetWizardStep nextStep)
                                  Just (Right r) -> dispatch (Finalize r)
                            , children: [ R.text nextText ]
                            }
                        ]
                  }
              ]
          }
