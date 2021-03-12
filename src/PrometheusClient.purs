{-
 Copyright (c) 2012-2017 "JUSPAY Technologies"
 JUSPAY Technologies Pvt. Ltd. [https://www.juspay.in]
 This file is part of JUSPAY Platform.
 JUSPAY Platform is free software: you can redistribute it and/or modify
 it for only educational purposes under the terms of the GNU Affero General
 Public License (GNU AGPL) as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any later version.
 For Enterprise/Commerical licenses, contact <info@juspay.in>.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  The end user will
 be liable for all damages without limitation, which is caused by the
 ABUSE of the LICENSED SOFTWARE and shall INDEMNIFY JUSPAY for such
 damages, claims, cost, including reasonable attorney fee claimed on Juspay.
 The end user has NO right to claim any indemnification based on its use
 of Licensed Software. See the GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/agpl.html>.
-}
module Prometheus.Client where

import Prelude

import Effect (Effect)
import Foreign.Class (class Encode, encode)
import Data.Function.Uncurried (Fn2, Fn3, Fn6, runFn2, runFn3, runFn6)
import Node.Express.Types (Response, Request)

foreign import data Metric :: Type
foreign import data Timer :: Type
foreign import emptyTimer :: Effect Timer
foreign import promClusterMetrics :: Fn3 Request Response (Effect Unit) (Effect Unit)
foreign import initCounterImpl :: Fn3 String String (Array String) (Effect Metric)
foreign import initHistogramImpl :: Fn6 String String (Array String) Number Number Number (Effect Metric)
foreign import incrementCounterImpl :: forall a. Fn2 Metric a (Effect Metric)
foreign import addLabelsImpl :: forall labels. Fn2 Metric labels (Effect Metric)
foreign import startTimerImpl :: forall labels. Fn2 Metric labels (Effect Timer)
foreign import endTimerImpl :: forall labels. Fn3 Metric labels Timer (Effect Unit)
foreign import initGaugeImpl :: Fn3 String String (Array String) (Effect Metric)
foreign import setGaugeImpl :: forall a. Fn3 Metric a Number (Effect Metric)

initCounter ::  String -> String -> Array String -> Effect  Metric
initCounter name desc labels = runFn3 initCounterImpl name desc labels

incrementCounter :: forall a . Encode a => Metric -> a -> Effect Metric
incrementCounter counter labelRec = runFn2 incrementCounterImpl counter (encode labelRec)

initHistogram ::  String -> Array String -> Number -> Number -> Number -> Effect  Metric
initHistogram name labels bucketStart bucketEnd factor =
  runFn6 initHistogramImpl name name labels bucketStart bucketEnd factor

startTimer :: forall a. Encode a => Metric -> a -> Effect Timer
startTimer histogram labelRec  =
  runFn2 startTimerImpl histogram (encode labelRec)

endTimer :: forall a. Encode a => Metric -> a -> Timer  -> Effect Unit
endTimer histogram labels timer = runFn3 endTimerImpl histogram (encode labels) timer


initGauge :: String -> String -> Array String -> Effect Metric
initGauge name desc labels = runFn3 initGaugeImpl name desc labels

setGauge :: forall a. Encode a => Metric -> a -> Number -> Effect Metric
setGauge gauge labelRec value = runFn3 setGaugeImpl gauge (encode lab