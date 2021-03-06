module Interpret.Modules.Collections.Vector (vectorModule) where

import Control.Monad.Except (throwError, catchError)

import qualified Data.Map as Map
import Data.Vector

import qualified Interpret.Context as Context
import Data
import Interpret.Eval
import Interpret.Transform


  

fnConcat :: Expr -> Expr -> EvalM Expr  
fnConcat (Coll (Vector v1)) (Coll (Vector v2)) = pure $ Coll $ Vector (v1 <> v2)
fnConcat _ _ = lift $ throwError "concat expects strings as arguments"
mlsConcat = liftFun2 fnConcat (MVector (MVar "a"))
                              (MVector (MVar "a"))
                              (MVector (MVar "a"))

vectorModule :: Expr
vectorModule = Module $ Map.fromList [
  -- Types
  ("concat",  mlsConcat),
  ("⋅", mlsConcat)
  ]
