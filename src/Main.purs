module Main where

import Prelude (Unit, bind, pure, unit, ($), (<$>), (=<<))
import App.Slice as Slice
import Views.Result (mkResultView)
import Views.Form (mkFormView)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, component, useReducer, (/\))
import React.Basic.Hooks as React
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

mkApp :: Component Unit
mkApp = do
  viewForm <- mkFormView
  viewResult <- mkResultView
  component "App" \props -> React.do
    stateDispatch@(state /\ _) <- useReducer Slice.initialState Slice.reducer
    pure
      $ case state.result of
          Nothing -> viewForm stateDispatch
          Just result -> viewResult result

main :: Effect Unit
main = do
  mContainer <- getElementById "root" =<< (toNonElementParentNode <$> (document =<< window))
  case mContainer of
    Nothing -> throw "Could not find body."
    Just container -> do
      app <- mkApp
      render (app unit) container
