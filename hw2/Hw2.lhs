---
title: Homework #2, Due Friday 2/24/14
---

> {-# LANGUAGE TypeSynonymInstances #-}
> module Hw2 where

> import Control.Applicative hiding (empty, (<|>))
> import Data.Map
> import Control.Monad.State hiding (when)
> import Text.Parsec hiding (State, between)
> import Text.Parsec.Combinator hiding (between)
> import Text.Parsec.Char
> import Text.Parsec.String

This week's homework is presented as a literate Haskell file,
just like the lectures. This means that every line beginning with
`>` is interpreted as Haskell code by the compiler, while every other
line is ignored. (Think of this as the comments and code being reversed
from what they usually are.)

You can load this file into `ghci` and compile it with `ghc`
just like any other Haskell file, so long as you remember to save
it with a `.lhs` suffix.

To complete this homework, download [this file as plain text](Hw2.lhs) and
answer each question, filling in code where noted (i.e. where it says `error
"TBD"`).

Your code *must* typecheck against the given type signatures.
Feel free to add your own tests to this file to exercise the functions
you write.  Submit your homework by sending this file, filled in
appropriately, to `cse230@goto.ucsd.edu` with the subject "HW2"; you
will receive a confirmation email after submitting. 

Before starting this assignment:

1. Install `parsec3` via the command `cabal install parsec3`
2. Learn to read the [documentation](http://hackage.haskell.org)
3. Download the test files 
   [test.imp](/static/test.imp),
   [fact.imp](/static/fact.imp), 
   [abs.imp](/static/abs.imp), 
   [times.imp](/static/times.imp).

Problem 0: All About You
========================


Tell us your name, email and student ID, by replacing the respective
strings below

> myName  = ""
> myEmail = ""
> mySID   = ""


Problem 1: All About `foldl`
============================

Define the following functions by filling in the "error" portion:

1. Describe `foldl` and give an implementation:

> myFoldl :: (a -> b -> a) -> a -> [b] -> a
> myFoldl f b [] = b
> myFoldl f b (x:xs) = myFoldl f (f b x) xs

2. Using the standard `foldl` (not `myFoldl`), define the list reverse function:

> myReverse :: [a] -> [a]
> myReverse = Prelude.foldl (flip (:)) []

3. Define `foldr` in terms of `foldl`:

> myFoldr :: (a -> b -> b) -> b -> [a] -> b
> myFoldr f b xs = Prelude.foldl (flip f) b (myReverse xs)

4. Define `foldl` in terms of the standard `foldr` (not `myFoldr`):

> myFoldl2 :: (a -> b -> a) -> a -> [b] -> a
> myFoldl2 f b xs = Prelude.foldr (flip f) b (myReverse xs)

5. Try applying `foldl` to a gigantic list. Why is it so slow?
   Try using `foldl'` (from [Data.List](http://www.haskell.org/ghc/docs/latest/html/libraries/base/Data-List.html#3))
   instead; can you explain why it's faster?

   Haskell compilers commonly choose lazy evaluation as reduction order to reduce multiple redexes.
   The foldl function is defined in Haskell Prelude as

   foldl :: (a -> b -> a) -> a -> [b] -> a
   foldl f a [] = a
   foldl f a (x:xs) = foldl f (f a x) xs

   if we ran foldl (+) 0 [1..100] will become
   
   foldl (+) 0 [1..100]
=>  foldl (+) 0 (1:[2..100])
=>  foldl (+) (0 + 1) [2..100]
=>  foldl (+) (0 + 1) (2:[3..100])
=>  foldl (+) ((0 + 1) + 2) [3..100]
=>  foldl (+) ((0 + 1) + 2) (3:[4..100])
=>  foldl (+) (((0 + 1) + 2) + 3) [4..100]
=>  …

Thus the accumulating parameter grows without bounds, but the foldl is implemented as
foldl' :: (a -> b -> a) -> a -> [b] -> a
foldl' f a []     = a
foldl' f a (x:xs) = let a' = f a x
                    in seq a' (foldl' f a' xs)

 and now the evaluation proceeds as
 foldl' (+) 0 [1..100]
=>  foldl' (+) 0 (1:[2..100])
=>  let a' = 0 + 1 in seq a' (foldl' (+) a' [2..100])
=>  let a' = 1 in seq a' (foldl' (+) a' [2..100])
=>  foldl' (+) 1 [2..100]
=>  foldl' (+) 1 (2:[3..100])
=>  let a' = 1 + 2 in seq a' (foldl' (+) a' [3..100])
=>  let a' = 3 in seq a' (foldl' (+) a' [3..100])
=>  foldl' (+) 3 [3..100]
=>  …

The expression stays at a constant size due to the usage of seq, which makes sure that the 
accumulating parameter is evaluated before the next element in the list is processed.

[Reference: https://hackhands.com/lazy-evaluation-works-haskell, https://wiki.haskell.org/Fold]

Part 2: Binary Search Trees
===========================

Recall the following type of binary search trees:

> data BST k v = Emp 
>              | Bind k v (BST k v) (BST k v) 
>              deriving (Show)

Define a `delete` function for BSTs of this type:

> delete :: (Ord k) => k -> BST k v -> BST k v
> delete k Emp = Emp
> delete k (Bind k' v t1 t2) 
>    | k == k' = deleteR t1 t2
>    | k < k'  = Bind k' v (Hw2.delete k t1) t2
>    | k > k'  = Bind k' v t1 (Hw2.delete k t2)

Helper function deleteR, when the root of the tree or subtree is deleted,
then we put the right subtree of the root to be the right child of the right most node in the left subtree.

> deleteR :: BST k v -> BST k v -> BST k v
> deleteR Emp Emp           = Emp
> deleteR Emp r             = r
> deleteR l Emp             = l
> deleteR (Bind k v t1 t2) r = (Bind k v t1 (deleteR t2 r))   

Part 3: An Interpreter for WHILE 
================================

Next, you will use monads to build an evaluator for
a simple *WHILE* language. In this language, we will
represent different program variables as 

> type Variable = String

Programs in the language are simply values of the type

> data Statement =
>     Assign Variable Expression          -- x = e
>   | If Expression Statement Statement   -- if (e) {s1} else {s2}
>   | While Expression Statement          -- while (e) {s}
>   | Sequence Statement Statement        -- s1; s2
>   | Skip                                -- no-op
>   deriving (Show)

where expressions are variables, constants or 
binary operators applied to sub-expressions

> data Expression =
>     Var Variable                        -- x
>   | Val Value                           -- v 
>   | Op  Bop Expression Expression
>   deriving (Show)

and binary operators are simply two-ary functions

> data Bop = 
>     Plus     -- +  :: Int  -> Int  -> Int
>   | Minus    -- -  :: Int  -> Int  -> Int
>   | Times    -- *  :: Int  -> Int  -> Int
>   | Divide   -- /  :: Int  -> Int  -> Int
>   | Gt       -- >  :: Int -> Int -> Bool 
>   | Ge       -- >= :: Int -> Int -> Bool
>   | Lt       -- <  :: Int -> Int -> Bool
>   | Le       -- <= :: Int -> Int -> Bool
>   deriving (Show)

> data Value =
>     IntVal Int
>   | BoolVal Bool
>   deriving (Show)

We will represent the *store* i.e. the machine's memory, as an associative
map from `Variable` to `Value` 

> type Store = Map Variable Value

**Note:** we don't have exceptions (yet), so if a variable
is not found (eg because it is not initialized) simply return 
the value `0`. In future assignments, we will add this as a 
case where exceptions are thrown (the other case being type errors.)

We will use the standard library's `State` 
[monad](http://hackage.haskell.org/packages/archive/mtl/latest/doc/html/Control-Monad-State-Lazy.html#g:2)
to represent the world-transformer.
Intuitively, `State s a` is equivalent to the world-transformer 
`s -> (a, s)`. See the above documentation for more details. 
You can ignore the bits about `StateT` for now.

Expression Evaluator
--------------------

First, write a function 

> evalE :: Expression -> State Store Value

that takes as input an expression and returns a world-transformer that
returns a value. Yes, right now, the transformer doesnt really transform
the world, but we will use the monad nevertheless as later, the world may
change, when we add exceptions and such.

**Hint:** The value `get` is of type `State Store Store`. Thus, to extract 
the value of the "current store" in a variable `s` use `s <- get`.

> evalE (Var x)      = do
>                       s <- get
>                       return (findWithDefault (IntVal 0) x s)
> evalE (Val v)      = return v
> evalE (Op o e1 e2) = do
>                       (IntVal v1) <- evalE(e1)
>                       (IntVal v2) <- evalE(e2)
>                       case o of 
>                          Plus      -> return ( IntVal  (v1   +   v2))
>                          Minus     -> return ( IntVal  (v1   -   v2))
>                          Times     -> return ( IntVal  (v1   *   v2))
>                          Divide    -> return ( IntVal  (v1 `div` v2))
>                          Gt        -> return ( BoolVal (v1   >   v2))
>                          Ge        -> return ( BoolVal (v1   >=  v2))
>                          Lt        -> return ( BoolVal (v1   <   v2))
>                          Le        -> return ( BoolVal (v1   <=  v2))


Statement Evaluator
-------------------

Next, write a function

> evalS :: Statement -> State Store ()

that takes as input a statement and returns a world-transformer that
returns a unit. Here, the world-transformer should in fact update the input
store appropriately with the assignments executed in the course of
evaluating the `Statement`.

**Hint:** The value `put` is of type `Store -> State Store ()`. 
Thus, to "update" the value of the store with the new store `s'` 
do `put s`.

> evalS w@(While e s)    = do
>                          v <- evalE e
>                          case v of
>                             IntVal _      -> evalS Skip
>                             BoolVal False -> evalS Skip
>                             BoolVal True  -> do evalS s; evalS w
> evalS Skip             = return ()
> evalS (Sequence s1 s2) = do evalS s1; evalS s2
> evalS (Assign x e )    = do
>                          s <- get
>                          v <- evalE e
>                          put $ insert x v s
> evalS (If e s1 s2)     = do
>                          v <- evalE e
>                          case v of
>                             IntVal _       -> evalS Skip
>                             BoolVal True   -> evalS s1
>                             BoolVal False  -> evalS s2

In the `If` case, if `e` evaluates to a non-boolean value, just skip both
the branches. (We will convert it into a type error in the next homework.)
Finally, write a function 

> execS :: Statement -> Store -> Store
> execS s = execState $ evalS s

such that `execS stmt store` returns the new `Store` that results
from evaluating the command `stmt` from the world `store`. 
**Hint:** You may want to use the library function 

~~~~~{.haskell}
execState :: State s a -> s -> s
~~~~~

When you are done with the above, the following function will 
"run" a statement starting with the `empty` store (where no 
variable is initialized). Running the program should print 
the value of all variables at the end of execution.

> run :: Statement -> IO ()
> run stmt = do putStrLn "Output Store:" 
>               putStrLn $ show $ execS stmt empty

Here are a few "tests" that you can use to check your implementation.

> w_test = (Sequence (Assign "X" (Op Plus (Op Minus (Op Plus (Val (IntVal 1)) (Val (IntVal 2))) (Val (IntVal 3))) (Op Plus (Val (IntVal 1)) (Val (IntVal 3))))) (Sequence (Assign "Y" (Val (IntVal 0))) (While (Op Gt (Var "X") (Val (IntVal 0))) (Sequence (Assign "Y" (Op Plus (Var "Y") (Var "X"))) (Assign "X" (Op Minus (Var "X") (Val (IntVal 1))))))))

> w_fact = (Sequence (Assign "N" (Val (IntVal 2))) (Sequence (Assign "F" (Val (IntVal 1))) (While (Op Gt (Var "N") (Val (IntVal 0))) (Sequence (Assign "X" (Var "N")) (Sequence (Assign "Z" (Var "F")) (Sequence (While (Op Gt (Var "X") (Val (IntVal 1))) (Sequence (Assign "F" (Op Plus (Var "Z") (Var "F"))) (Assign "X" (Op Minus (Var "X") (Val (IntVal 1)))))) (Assign "N" (Op Minus (Var "N") (Val (IntVal 1))))))))))

As you can see, it is rather tedious to write the above tests! They
correspond to the code in the files `test.imp` and `fact.imp`. When you are
done, you should get

~~~~~{.haskell}
ghci> run w_test
Output Store:
fromList [("X",IntVal 0),("Y",IntVal 10)]

ghci> run w_fact
Output Store:
fromList [("F",IntVal 2),("N",IntVal 0),("X",IntVal 1),("Z",IntVal 2)]
~~~~~

Problem 4: A Parser for WHILE 
=============================

It is rather tedious to have to specify individual programs as Haskell
values. For this problem, you will use parser combinators to build a parser
for the WHILE language from the previous problem.

Parsing Constants
-----------------

First, we will write parsers for the `Value` type

> valueP :: Parser Value
> valueP = intP <|> boolP

To do so, fill in the implementations of

> intP :: Parser Value
> intP = do
>        x <- many1 digit
>        return $ IntVal $ read x

Next, define a parser that will accept a 
particular string `s` as a given value `x`

> constP :: String -> a -> Parser a
> constP s x = do
>              string s
>              return x

and use the above to define a parser for boolean values 
where `"true"` and `"false"` should be parsed appropriately.

> boolP :: Parser Value
> boolP = choice[try (constP "true" (BoolVal True)),
>               try (constP "false" (BoolVal False))]

Continue to use the above to parse the binary operators

> opP :: Parser Bop 
> opP =   choice[try (constP ">="   Ge),
>            try (constP "<="   Le),
>               try (constP "+"    Plus),
>               try (constP "-"    Minus),
>               try (constP "*"    Times),
>               try (constP "/"    Divide),
>               try (constP ">"    Gt),
>               try (constP "<"    Lt)]

Parsing Expressions 
-------------------

Next, the following is a parser for variables, where each 
variable is one-or-more uppercase letters. 

> varP :: Parser Variable
> varP = many1 upper

Use the above to write a parser for `Expression` values

> exprP :: Parser Expression
> exprP = choice[try expExprP, try parenExprP, try varExprP, try valExprP]
>     where
>        expExprP = do
>           x <- choice[try varExprP, try valExprP, try parenExprP]
>           skipMany space
>           o <- opP
>           skipMany space
>           y <- exprP
>           return $ Op o x y
>        parenExprP = do
>           string "("
>           x <- exprP
>           string ")"
>           return $ x
>        varExprP = do
>           v <- varP
>           return $ Var v
>        valExprP = do
>           v <- valueP
>           return $ Val v

Parsing Statements
------------------

Next, use the expression parsers to build a statement parser

> statementP :: Parser Statement
> statementP = choice [try sequenceP, try ifP, try whileP, try assignP, try skipP]
>     where
>        sequenceP = do
>           s1 <- choice [try ifP, try whileP, try assignP, try skipP]
>           skipMany space
>           string ";"
>           skipMany space
>           s2 <- statementP
>           return $ Sequence s1 s2
>        ifP = do
>           string "if"
>           skipMany space
>           e  <- exprP
>           skipMany space
>           string "then"
>           skipMany space
>           s1 <- statementP
>           skipMany space
>           string "else"
>           skipMany space
>           s2 <- statementP
>           skipMany space
>           string "endif"
>           return $ If e s1 s2
>        whileP = do
>           string "while"
>           skipMany space
>           e <- exprP
>           skipMany space
>           string "do"
>           skipMany space
>           s <- statementP
>           skipMany space
>           string "endwhile"
>           return $ While e s
>        assignP = do
>           v <- varP
>           skipMany space
>           string ":="
>           skipMany space
>           e <- exprP
>           return $ Assign v e
>        skipP = do
>           string "skip"
>           return Skip

When you are done, we can put the parser and evaluator together 
in the end-to-end interpreter function

> runFile s = do p <- parseFromFile statementP s
>                case p of
>                  Left err   -> print err
>                  Right stmt -> run stmt

When you are done you should see the following at the ghci prompt

~~~~~{.haskell}
ghci> runFile "test.imp"
Output Store:
fromList [("X",IntVal 0),("Y",IntVal 10)]

ghci> runFile "fact.imp" 
Output Store:
fromList [("F",IntVal 2),("N",IntVal 0),("X",IntVal 1),("Z",IntVal 2)]
~~~~~





