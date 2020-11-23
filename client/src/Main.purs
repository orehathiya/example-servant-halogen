module Main where

import Prelude
import Affjax as AX
import Affjax.ResponseFormat as AXRF
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import Web.Event.Event (Event)
import Web.Event.Event as Event

main :: Effect Unit
main =
  runHalogenAff do
    body <- awaitBody
    runUI component unit body

type State
  = { loading :: Boolean
    , result :: Maybe String
    }

data Action
  = MakeRequest Event

component :: forall query input output m. MonadAff m => H.Component HH.HTML query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
    }

initialState :: forall i. i -> State
initialState _ = { loading: false, result: Nothing }

render :: forall m. State -> H.ComponentHTML Action () m
render st =
  HH.form
    [ HE.onSubmit \ev -> Just (MakeRequest ev) ]
    [ HH.h1_ [ HH.text "Look up user" ]
    , HH.button
        [ HP.disabled st.loading
        , HP.type_ HP.ButtonSubmit
        ]
        [ HH.text "Fetch" ]
    , HH.p_
        [ HH.text (if st.loading then "Working..." else "") ]
    , HH.div_ case st.result of
        Nothing -> []
        Just res ->
          [ HH.h2_
              [ HH.text "Response:" ]
          , HH.pre_
              [ HH.code_ [ HH.text res ] ]
          ]
    ]

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction = case _ of
  MakeRequest event -> do
    H.liftEffect $ Event.preventDefault event
    H.modify_ _ { loading = true }
    response <- H.liftAff $ AX.get AXRF.string ("http://localhost:3000/user/get/Alice")
    H.modify_ _ { loading = false, result = map _.body (hush response) }
