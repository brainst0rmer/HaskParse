module Interpreter where

import Mylang.Abs
import qualified Data.Map as Map
import Control.Monad.State
import System.IO

-- Environment: maps variable names to values
type Env = Map.Map String Value

-- Values used in the interpreter
data Value =
    IntVal Integer
  | ArrayVal (Map.Map Integer Integer)
  deriving (Show, Eq)

-- Interpreter monad
type Interp a = StateT Env IO a

-- Entry point
interpret :: Program -> IO ()
interpret (Prog _ stmt) = evalStateT (interpretCompoundStatement stmt) Map.empty

-- Interpret a compound block
interpretCompoundStatement :: CompoundStatement -> Interp ()
interpretCompoundStatement (CompSt stmtList) =
  interpretStatementList stmtList

-- Interpret a list of statements
interpretStatementList :: StatementList -> Interp ()
interpretStatementList (ListStmt stmt) = interpretStatement stmt
interpretStatementList (ListStmtCons stmt rest) = do
  interpretStatement stmt
  interpretStatementList rest

-- Interpret a single statement
interpretStatement :: Statement -> Interp ()
interpretStatement (AssignStmt var AssignmentOp expr) = do
  val <- evaluateExpression expr
  let name = getVarName var
  modify (Map.insert name val)

interpretStatement (ProcStmt procStmt) = interpretProcedureStatement procStmt
interpretStatement (CompStmt compStmt) = interpretCompoundStatement compStmt

interpretStatement (IfThenElseStmt expr s1 s2) = do
  IntVal cond <- evaluateExpression expr
  if cond /= 0 then interpretStatement s1 else interpretStatement s2

interpretStatement (IfThenStmt expr s1) = do
  IntVal cond <- evaluateExpression expr
  when (cond /= 0) $ interpretStatement s1

interpretStatement (WhileDoStmt expr body) = loop
  where
    loop = do
      IntVal cond <- evaluateExpression expr
      when (cond /= 0) $ interpretStatement body >> loop

interpretStatement (ReadStmt (ReadSt var)) = interpretRead var
interpretStatement (WriteStmt (WriteSt expr)) = interpretWrite expr

-- Read from stdin
interpretRead :: Variable -> Interp ()
interpretRead var = do
  let name = getVarName var
  liftIO $ putStr (name ++ "? ") >> hFlush stdout
  input <- liftIO getLine
  case reads input of
    [(n, "")] -> modify (Map.insert name (IntVal n))
    _         -> error $ "Invalid input for variable: " ++ name

-- Print to stdout
interpretWrite :: Expression -> Interp ()
interpretWrite expr = do
  IntVal n <- evaluateExpression expr
  liftIO $ print n

-- Handle procedure calls (not implemented)
interpretProcedureStatement :: ProcedureStatement -> Interp ()
interpretProcedureStatement (ProcNoArgs (Id name)) =
  error $ "Procedure '" ++ name ++ "' is not defined"

interpretProcedureStatement (ProcWithArgs (Id name) _) =
  error $ "Procedure '" ++ name ++ "' is not defined"

-- Evaluate expressions
evaluateExpression :: Expression -> Interp Value
evaluateExpression (EAdd e1 t) = do
  IntVal v1 <- evaluateExpression e1
  IntVal v2 <- evaluateTerm t
  return $ IntVal (v1 + v2)

evaluateExpression (ESub e1 t) = do
  IntVal v1 <- evaluateExpression e1
  IntVal v2 <- evaluateTerm t
  return $ IntVal (v1 - v2)

evaluateExpression (ETerm t) = evaluateTerm t

evaluateTerm :: Term -> Interp Value
evaluateTerm (EMul t1 f) = do
  IntVal v1 <- evaluateTerm t1
  IntVal v2 <- evaluateFactor f
  return $ IntVal (v1 * v2)

evaluateTerm (EDiv t1 f) = do
  IntVal v1 <- evaluateTerm t1
  IntVal v2 <- evaluateFactor f
  if v2 == 0
    then error "Division by zero"
    else return $ IntVal (v1 `div` v2)

evaluateTerm (ETermF f) = evaluateFactor f

evaluateFactor :: Factor -> Interp Value
evaluateFactor (EInt (MyInteger n)) = return $ IntVal (read n)
evaluateFactor (EVar var) = do
  let name = getVarName var
  env <- get
  case Map.lookup name env of
    Just val -> return val
    Nothing  -> error $ "Undefined variable: " ++ name
evaluateFactor (EParen expr) = evaluateExpression expr

-- Helper to get variable name
getVarName :: Variable -> String
getVarName (Var (Id name)) = name

-- Evaluate expression list (used for procedures)
evaluateExpressionList :: ExpressionList -> Interp [Value]
evaluateExpressionList (ListExp e) = do
  v <- evaluateExpression e
  return [v]
evaluateExpressionList (ListExpCons e rest) = do
  v <- evaluateExpression e
  vs <- evaluateExpressionList rest
  return (v : vs)
