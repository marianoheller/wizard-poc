module Features.Steps.Step03 where

import Prelude

import Features.Steps.Step01 (FirstStepResult)
import Features.Steps.Step02 (SecondStepResult)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), maybe)
import Data.String.NonEmpty (toString) as NES
import Data.Symbol (SProxy(..))
import Lumi.Components.Form (FormBuilder, Validated)
import Lumi.Components.Form as F
import Lumi.Components.LabeledField (RequiredField(..))
import Lumi.Components.Text as T

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
