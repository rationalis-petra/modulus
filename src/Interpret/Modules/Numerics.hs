module Interpret.Modules.Numerics (numModule) where

import Control.Monad.Except (throwError, catchError)

import qualified Data.Map as Map

import Data
import Interpret.Eval
import Interpret.Transform

int_t = MPrim IntT
bool_t = MPrim BoolT
float_t = MPrim FloatT

mkFloatUni :: (Float -> Float) -> Expr
mkFloatUni f = 
  liftFun newf float_t float_t
  where
    newf :: Expr -> EvalM Expr
    newf (PrimE (Float f1)) =
      pure $ PrimE $ Float $ f f1
    newf x =
      lift $ throwError ("bad arg to inbuilt float function" <> show x)


mkFloatOp :: (Float -> Float -> Float) -> Expr
mkFloatOp f = 
  liftFun2 newf float_t float_t float_t
  where
    newf :: Expr -> Expr -> EvalM Expr
    newf (PrimE (Float f1)) (PrimE (Float f2)) =
      pure $ PrimE $ Float $ f f1 f2
    newf x y =
      lift $ throwError ("bad arg to inbuilt float function"
                         <> show x <> ", " <> show y)

mkFltCmp :: (Float -> Float -> Bool) -> Expr
mkFltCmp f = 
  liftFun2 newf float_t float_t bool_t
  where
    newf :: Expr -> Expr -> EvalM Expr
    newf (PrimE (Float n1)) (PrimE (Float n2)) =
      pure $ PrimE $ Bool $ f n1 n2
    newf x y =
      lift $ throwError ("bad arg to inbuilt integer function" ++
                         show x ++ ", " ++ show y)

  
mkIntUni :: (Integer -> Integer) -> Expr
mkIntUni f = 
  liftFun newf int_t int_t
  where
    newf :: Expr -> EvalM Expr
    newf (PrimE (Int n1)) =
      pure $ PrimE $ Int $ f n1
    newf x =
      lift $ throwError ("bad arg to inbuilt float function" <> show x)

mkIntOp :: (Integer -> Integer -> Integer) -> Expr
mkIntOp f = 
  liftFun2 newf int_t int_t int_t
  where
    newf :: Expr -> Expr -> EvalM Expr
    newf (PrimE (Int n1)) (PrimE (Int n2)) =
      pure $ PrimE $ Int $ f n1 n2
    newf x y =
      lift $ throwError ("bad arg to inbuilt integer function" ++
                         show x ++ ", " ++ show y)

mkCmpOp :: (Integer -> Integer -> Bool) -> Expr
mkCmpOp f = 
  liftFun2 newf int_t int_t bool_t
  where
    newf :: Expr -> Expr -> EvalM Expr
    newf (PrimE (Int n1)) (PrimE (Int n2)) =
      pure $ PrimE $ Bool $ f n1 n2
    newf x y =
      lift $ throwError ("bad arg to inbuilt integer function" ++
                         show x ++ ", " ++ show y)

mkBoolOp :: (Bool -> Bool -> Bool) -> Expr
mkBoolOp f = 
  liftFun2 newf bool_t bool_t bool_t
  where
    newf :: Expr -> Expr -> EvalM Expr
    newf (PrimE (Bool b1)) (PrimE (Bool b2)) =
      pure $ PrimE $ Bool $ f b1 b2
    newf x y =
      lift $ throwError ("bad arg to inbuilt bool function" ++
                         show x ++ ", " ++ show y)

mkBoolSing :: (Bool -> Bool) -> Expr
mkBoolSing f = 
  liftFun newf bool_t bool_t
  where
    newf :: Expr -> EvalM Expr
    newf (PrimE (Bool b)) =
      pure $ PrimE $ Bool $ f b
    newf x =
      lift $ throwError ("bad arg to inbuilt bool function" ++
                         show x)


intModule :: Map.Map String Expr  
intModule = Map.fromList
  [("t", Type int_t),
   ("int", Type int_t),
   ("+", mkIntOp (+)),
   ("-", mkIntOp (-)),
   ("*", mkIntOp (*)),
   -- TODO: divide does not belong in a ring; but we want int to be a ring
   -- maybe?? 
   ("quot", mkIntOp (quot)),
   ("rem", mkIntOp (rem)),
   ("add-inv", mkIntUni (\x -> -x)),

   ("^", mkIntOp (^)),

   ("e0", PrimE (Int 0)),
   ("e1", PrimE (Int 1)),

   ("<", mkCmpOp (<)),
   ("???", mkCmpOp (<=)),
   (">", mkCmpOp (>)),
   ("???", mkCmpOp (>=)),
   ("=", mkCmpOp (==)),
   ("???", mkCmpOp (/=))
  ]

floatModule :: Map.Map String Expr 
floatModule = Map.fromList
  [("t",     Type float_t),
   ("float", Type float_t),
   ("+", mkFloatOp (+)),
   ("-", mkFloatOp (-)),
   ("*", mkFloatOp (*)),
   ("/", mkFloatOp (/)),
   ("^", mkFloatOp (**)),

   ("e0", PrimE (Float 0.0)),
   ("e1", PrimE (Float 1.0)),
   
   ("add-inv", mkFloatUni (\x -> -x)),
   ("mul-inv", mkFloatUni (\x -> 1/x)),

   ("<", mkFltCmp (<)),
   ("???", mkFltCmp (<=)),
   (">", mkFltCmp (>)),
   ("???", mkFltCmp (>=)),
   ("=", mkFltCmp (==)),
   ("???", mkFltCmp (/=))
  ]

numModule :: Map.Map String Expr
numModule = Map.fromList
  [("Int", Module intModule),
   ("Float", Module floatModule),

   ("???", mkBoolOp (&&)),
   ("???", mkBoolOp (||)),
   ("???", mkBoolOp (/=)),
   ("not", mkBoolSing not)
   ]

binfloat = MArr float_t (MArr float_t float_t)
unifloat = MArr float_t float_t
  
binint = MArr int_t (MArr int_t int_t)
uniint = MArr int_t int_t
intcompare = MArr int_t (MArr int_t bool_t)
floatCompare = MArr float_t (MArr float_t bool_t)
binbool = MArr bool_t (MArr bool_t bool_t)
