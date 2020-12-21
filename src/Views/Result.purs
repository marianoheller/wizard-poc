module Views.Result where

import Prelude
import Features.Wizard (Result)
import React.Basic.DOM as R
import React.Basic.Hooks (Component, component)

mkResultView :: Component Result
mkResultView = do
  component "ResultView" \{ text, occupation } -> React.do
    pure
      $ R.div
          { style: R.css { alignSelf: "stretch" }
          , children:
              [ R.p_ [ R.text "Dilly dily data, my magic's a done! I'm a Wizard, after all." ]
              , R.p_ [ R.text text ]
              , R.p_ [ R.text "From all this information, I can only conclude that yourself are." ]
              ]
          }
