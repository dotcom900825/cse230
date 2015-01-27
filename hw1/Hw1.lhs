---
title: Homework #1, Due Friday, 1/31/14
---

Haskell Formalities
-------------------

We declare that this is the Hw1 module and import some libraries:

> module Hw1 where
> import SOE
> import Play
> import XMLTypes


Part 0: All About You
---------------------

Tell us your name, email and student ID, by replacing the respective
strings below

> myName  = ""
> myEmail = ""
> mySID   = ""


Preliminaries
-------------

Before starting this assignment:

* Download and install the [Haskell Platform](http://www.haskell.org/platform/).
* Download the [SOE code bundle](/static/SOE-cse230.tgz).

* Verify that it works by changing into the `SOE/src` directory and
   running `ghci Draw.lhs`, then typing `main0` at the prompt:
 
~~~
cd SOE/src
ghci Draw.lhs
*Draw> main0
~~~

  You should see a window with some shapes in it.

**NOTE:** If you have trouble installing SOE, [see this page](soe-instructions.html)

5. Download the required files for this assignment: [hw1.tar.gz](/static/hw1.tar.gz).
   Unpack the files and make sure that you can successfully run the main program (in `Main.hs`).
   We've provided a `Makefile`, which you can use if you like. You should see this output:

~~~
Main: Define me!
~~~

Part 1: Defining and Manipulating Shapes
----------------------------------------

You will write all of your code in the `hw1.lhs` file, in the spaces
indicated. Do not alter the type annotations --- your code must
typecheck with these types to be accepted.

The following are the definitions of shapes:

> data Shape = Rectangle Side Side
>            | Ellipse Radius Radius
>            | RtTriangle Side Side
>            | Polygon [Vertex]
>            deriving Show
> 
> type Radius = Float 
> type Side   = Float
> type Vertex = (Float, Float)

1. Below, define functions `rectangle` and `rtTriangle` as suggested
   at the end of Section 2.1 (Exercise 2.1). Each should return a Shape
   built with the Polygon constructor.

> rectangle :: Side -> Side -> Shape
> rectangle a b = Polygon [(0, 0), (a, 0), (a, b), (0, b)] 

> rtTriangle :: Side -> Side -> Shape
> rtTriangle a b = Polygon [(0, 0), (a, 0), (0, b)]

2. Define a function

> sides :: Shape -> Int
> sides (Rectangle s1 s2)   = 4
> sides (Ellipse r1 r2)     = 42
> sides (RtTriangle s1 s2)  = 3
> sides (Polygon pts)       
>      | (length pts) <= 2  = 0
>      | otherwise          = length pts

  which returns the number of sides a given shape has.
  For the purposes of this exercise, an ellipse has 42 sides,
  and empty polygons, single points, and lines have zero sides.

3. Define a function

> bigger :: Shape -> Float -> Shape
> bigger (Rectangle s1 s2) e = Rectangle (s1 * (sqrt e)) (s2 * (sqrt e))
> bigger (Ellipse r1 r2) e = Ellipse (r1 * (sqrt e)) (r2 * (sqrt e))
> bigger (RtTriangle s1 s2) e = RtTriangle (s1 * (sqrt e)) (s2 * (sqrt e))
> bigger (Polygon xs) e = Polygon (map (\(a, b) -> (a * (sqrt e), b * (sqrt e))) xs)


  that takes a shape `s` and expansion factor `e` and returns
  a shape which is the same as (i.e., similar to in the geometric sense)
  `s` but whose area is `e` times the area of `s`.

4. The Towers of Hanoi is a puzzle where you are given three pegs,
   on one of which are stacked $n$ discs in increasing order of size.
   To solve the puzzle, you must move all the discs from the starting peg
   to another by moving only one disc at a time and never stacking
   a larger disc on top of a smaller one.
   
   To move $n$ discs from peg $a$ to peg $b$ using peg $c$ as temporary storage:
   
   1. Move $n - 1$ discs from peg $a$ to peg $c$.
   2. Move the remaining disc from peg $a$ to peg $b$.
   3. Move $n - 1$ discs from peg $c$ to peg $b$.
   
   Write a function
   
> hanoi :: Int -> String -> String -> String -> IO ()
> hanoi 1 a b c         = putStrLn("move disc from " ++ a ++ " to " ++ b)
> hanoi n a b c         = 
>          do hanoi (n - 1) a c b
>             putStrLn("move disc from " ++ a ++ " to " ++ b)
>             hanoi (n - 1) c b a

  that, given the number of discs $n$ and peg names $a$, $b$, and $c$,
  where a is the starting peg,
  emits the series of moves required to solve the puzzle.
  For example, running `hanoi 2 "a" "b" "c"`

  should emit the text

~~~  
move disc from a to c
move disc from a to b
move disc from c to b
~~~

Part 2: Drawing Fractals
------------------------

1. The Sierpinski Carpet is a recursive figure with a structure similar to
   the Sierpinski Triangle discussed in Chapter 3:

![Sierpinski Carpet](/static/scarpet.png)

Write a function `sierpinskiCarpet` that displays this figure on the
screen:

> sierpinskiCarpet :: IO ()
> sierpinskiCarpet = runGraphics (
>                       do w <- openWindow "Sierpinski's Rec" (243, 243)
>                          sierpinskiRec w 0 0 243
>                          k <- getKey w
>                          closeWindow w)

Do the recursive rectangle:

> sierpinskiRec :: Window -> Int -> Int -> Int -> IO ()
> sierpinskiRec w x y size = 
>       if size <= 1
>       then drawRectangle x y size w
>       else let size2 = size `div` 3
>         in do sierpinskiRec w x y size2
>               sierpinskiRec w (x + size2) y size2
>               sierpinskiRec w (x + size2 * 2) y size2

>               sierpinskiRec w x (y + size2) size2
>               sierpinskiRec w (x + size2 * 2) (y + size2) size2

>               sierpinskiRec w x (y + size2 * 2) size2
>               sierpinskiRec w (x+size2) (y + size2 * 2) size2               
>               sierpinskiRec w (x + size2 * 2) ( y + size2 * 2) size2

Drawing the rectangle: 

> drawRectangle :: Int -> Int -> Int -> Window -> IO ()
> drawRectangle x y size w = 
>     drawInWindow w (withColor White (polygon [(x, y), (x + size,y), (x + size, y + size), (x , y + size)]))

Note that you either need to run your program in `SOE/src` or add this
path to GHC's search path via `-i/path/to/SOE/src/`.
Also, the organization of SOE has changed a bit, so that now you use
`import SOE` instead of `import SOEGraphics`.

2. Write a function `myFractal` which draws a fractal pattern of your
   own design.  Be creative!  The only constraint is that it shows some
   pattern of recursive self-similarity.

> --Draw a diamond shape filled with white color
> drawDiamond :: Window -> Int -> Int -> Int -> IO ()
> drawDiamond w x y size = 
>     drawInWindow w (withColor White (polygon [(x, y), (x+size, y+size), (x, y+(2*size)), (x-size, y+size)]))

> --Recursive split diamond into five small diamonds
> drawFractal w x y size = 
>   if size <= 3
>   then do drawDiamond w x y size
>   else let size2 = size `div` 3
>     in do drawFractal w x y size2
>           drawFractal w x (y+(2*size2)) size2
>           drawFractal w x (y+(4*size2)) size2
>           drawFractal w (x+(2*size2)) (y+(2*size2)) size2
>           drawFractal w (x-(2*size2)) (y+(2*size2)) size2

> myFractal :: IO ()
> myFractal
>   = runGraphics (
>     do w <- openWindow "My Fractal" (500, 500)
>        drawFractal w 250 0 243
>        k <- getKey w
>        closeWindow w 
>     )

Part 3: Recursion Etc.
----------------------

First, a warmup. Fill in the implementations for the following functions.

(Your `maxList` and `minList` functions may assume that the lists
they are passed contain at least one element.)

Write a *non-recursive* function to compute the length of a list

> lengthNonRecursive :: [a] -> Int
> lengthNonRecursive = foldr (\_ x -> 1 + x) 0

`doubleEach [1,20,300,4000]` should return `[2,40,600,8000]`

> doubleEach :: [Int] -> [Int]
> doubleEach [] = []
> doubleEach (x:xs) = x * 2 : doubleEach xs

Now write a *non-recursive* version of the above.

> doubleEachNonRecursive :: [Int] -> [Int]
> doubleEachNonRecursive = map(\x -> x * 2)

`pairAndOne [1,20,300]` should return `[(1,2), (20,21), (300,301)]`

> pairAndOne :: [Int] -> [(Int, Int)]
> pairAndOne [] = []
> pairAndOne (x:xs) = (x, x + 1) : pairAndOne xs 


Now write a *non-recursive* version of the above.

> pairAndOneNonRecursive :: [Int] -> [(Int, Int)]
> pairAndOneNonRecursive = map (\x -> (x, x + 1))

`addEachPair [(1,2), (20,21), (300,301)]` should return `[3,41,601]`


> addEachPair :: [(Int, Int)] -> [Int]
> addEachPair [] = []
> addEachPair ((x1,x2):xs) = x1 + x2 : addEachPair xs 

Now write a *non-recursive* version of the above.

> addEachPairNonRecursive :: [(Int, Int)] -> [Int]
> addEachPairNonRecursive = map (\(x1,x2) -> x1 + x2)

`minList` should return the *smallest* value in the list. You may assume the
input list is *non-empty*.

> minList :: [Int] -> Int
> minList [x] = x
> minList (x:xs) | x < minTail = x
>                | otherwise   = minTail
>                where minTail = minList xs

Now write a *non-recursive* version of the above.

> minListNonRecursive :: [Int] -> Int
> minListNonRecursive (x:xs)= foldl (min) x xs 

`maxList` should return the *largest* value in the list. You may assume the
input list is *non-empty*.

> maxList :: [Int] -> Int
> maxList [x] = x
> maxList (x:xs) | x > maxTail = x 
>                | otherwise   = maxTail 
>                where maxTail = maxList xs

Now write a *non-recursive* version of the above.

> maxListNonRecursive :: [Int] -> Int
> maxListNonRecursive (x:xs) = foldl (max) x xs 

Now, a few functions for this `Tree` type.

> data Tree a = Leaf a | Branch (Tree a) (Tree a)
>               deriving (Show, Eq)

> funcFold :: (a -> a -> a) -> (b -> a) -> Tree b -> a
> funcFold func leafFunc (Leaf a) = leafFunc a
> funcFold func leafFunc (Branch b1 b2) = func (funcFold func leafFunc b1) (funcFold func leafFunc b2)

`fringe t` should return a list of all the values occurring as a `Leaf`.
So: `fringe (Branch (Leaf 1) (Leaf 2))` should return `[1,2]`

> fringe :: Tree a -> [a]
> fringe = funcFold (++) (:[])

`treeSize` should return the number of leaves in the tree. 
So: `treeSize (Branch (Leaf 1) (Leaf 2))` should return `2`.

> treeSize :: Tree a -> Int
> treeSize = funcFold (+) (\_ -> 1)

`treeSize` should return the height of the tree.
So: `height (Branch (Leaf 1) (Leaf 2))` should return `1`.

> treeHeight :: Tree a -> Int
> treeHeight = funcFold (\x y -> 1 + max x y) (\_ -> 0)

Now, a tree where the values live at the nodes not the leaf.

> data InternalTree a = ILeaf | IBranch a (InternalTree a) (InternalTree a)
>                       deriving (Show, Eq)

`takeTree n t` should cut off the tree at depth `n`.
So `takeTree 1 (IBranch 1 (IBranch 2 ILeaf ILeaf) (IBranch 3 ILeaf ILeaf)))`
should return `IBranch 1 ILeaf ILeaf`.

> takeTree :: Int -> InternalTree a -> InternalTree a
> takeTree 0 _ = ILeaf
> takeTree _ ILeaf = ILeaf
> takeTree n (IBranch size a1 a2) = IBranch size (takeTree (n-1) a1) (takeTree (n-1) a2)


`takeTreeWhile p t` should cut of the tree at the nodes that don't satisfy `p`.
So: `takeTreeWhile (< 3) (IBranch 1 (IBranch 2 ILeaf ILeaf) (IBranch 3 ILeaf ILeaf)))`
should return `(IBranch 1 (IBranch 2 ILeaf ILeaf) ILeaf)`.

> takeTreeWhile :: (a -> Bool) -> InternalTree a -> InternalTree a
> takeTreeWhile _ ILeaf = ILeaf
> takeTreeWhile fn (IBranch n t1 t2)  
>             | fn n = IBranch n (takeTreeWhile fn t1) (takeTreeWhile fn t2)
>             | otherwise = ILeaf
 
Write the function map in terms of foldr:

> myMap :: (a -> b) -> [a] -> [b]
> myMap fn [] = []
> myMap fn xs = foldr (\arrayTail array -> (fn arrayTail):array) [] xs

Part 4: Transforming XML Documents
----------------------------------

The rest of this assignment involves transforming XML documents.
To keep things simple, we will not deal with the full generality of XML,
or with issues of parsing. Instead, we will represent XML documents as
instances of the following simpliﬁed type:

~~~~
data SimpleXML =
   PCDATA String
 | Element ElementName [SimpleXML]
 deriving Show

type ElementName = String
~~~~

That is, a `SimpleXML` value is either a `PCDATA` ("parsed character
data") node containing a string or else an `Element` node containing a
tag and a list of sub-nodes.

The file `Play.hs` contains a sample XML value. To avoid getting into
details of parsing actual XML concrete syntax, we'll work with just
this one value for purposes of this assignment. The XML value in
`Play.hs` has the following structure (in standard XML syntax):

~~~
<PLAY>
  <TITLE>TITLE OF THE PLAY</TITLE>
  <PERSONAE>
    <PERSONA> PERSON1 </PERSONA>
    <PERSONA> PERSON2 </PERSONA>
    ... -- MORE PERSONAE
    </PERSONAE>
  <ACT>
    <TITLE>TITLE OF FIRST ACT</TITLE>
    <SCENE>
      <TITLE>TITLE OF FIRST SCENE</TITLE>
      <SPEECH>
        <SPEAKER> PERSON1 </SPEAKER>
        <LINE>LINE1</LINE>
        <LINE>LINE2</LINE>
        ... -- MORE LINES
      </SPEECH>
      ... -- MORE SPEECHES
    </SCENE>
    ... -- MORE SCENES
  </ACT>
  ... -- MORE ACTS
</PLAY>
~~~

* `sample.html` contains a (very basic) HTML rendition of the same
  information as `Play.hs`. You may want to have a look at it in your
  favorite browser.  The HTML in `sample.html` has the following structure
  (with whitespace added for readability):
  
~~~
<html>
  <body>
    <h1>TITLE OF THE PLAY</h1>
    <h2>Dramatis Personae</h2>
    PERSON1<br/>
    PERSON2<br/>
    ...
    <h2>TITLE OF THE FIRST ACT</h2>
    <h3>TITLE OF THE FIRST SCENE</h3>
    <b>PERSON1</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
    <b>PERSON2</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
    <h3>TITLE OF THE SECOND SCENE</h3>
    <b>PERSON3</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
  </body>
</html>
~~~

You will write a function `formatPlay` that converts an XML structure
representing a play to another XML structure that, when printed,
yields the HTML speciﬁed above (but with no whitespace except what's
in the textual data in the original XML).

> -- Pass in SinpleXML object in XML format
> -- Return a converted SimpleXML object in HTML format
> formatPlay :: SimpleXML -> SimpleXML
> formatPlay (Element name xs) = Element "html" [Element "body" (concatMap (playFormatXML 1) xs)]
>
>
> -- Function used to convert play from XML to HTML
> -- Parameters: Int       -> level of the tree for title formatting
> --             SimpleXML -> XML object before converting
> -- Return: [SimpleXML]   -> converted HTML objects in a list
> playFormatXML :: Int -> SimpleXML -> [SimpleXML]
> playFormatXML _ (PCDATA s) = [PCDATA s]
> playFormatXML n (Element name xs)
>   | name == "TITLE"     = titleFormatXML n xs
>   | name == "PERSONAE"  = (Element "h2" [PCDATA "Dramatis Personae"]) : concatMap (playFormatXML 1) xs
>   | name == "PERSONA"   = xs ++ [PCDATA "<br/>"] 
>   | name == "ACT"       = concatMap (playFormatXML 2) xs
>   | name == "SCENE"     = concatMap (playFormatXML 3) xs
>   | name == "SPEECH"    = concatMap (playFormatXML 4) xs
>   | name == "SPEAKER"   = [Element "b" xs] ++ [PCDATA "<br/>"]
>   | name == "LINE"      = xs ++ [PCDATA "<br/>"] 
>   | otherwise           = []
>
>
>
>
> -- Generic Function to convert title into HTML format
> -- Parameters: Int         -> size of the header that's >= 1
> --             [SimpleXML] -> A PCDATA object in a list
> -- Return:     [SimpleXML] -> Converted HTML string object in a list
> titleFormatXML :: Int -> [SimpleXML] -> [SimpleXML]
> titleFormatXML n x = [Element ("h" ++ show n) x]

The main action that we've provided below will use your function to
generate a ﬁle `dream.html` from the sample play. The contents of this
ﬁle after your program runs must be character-for-character identical
to `sample.html`.

> mainXML = do writeFile "dream.html" $ xml2string $ formatPlay play
>              testResults "dream.html" "sample.html"
>
> firstDiff :: Eq a => [a] -> [a] -> Maybe ([a],[a])
> firstDiff [] [] = Nothing
> firstDiff (c:cs) (d:ds) 
>      | c==d = firstDiff cs ds 
>      | otherwise = Just (c:cs, d:ds)
> firstDiff cs ds = Just (cs,ds)
> 
> testResults :: String -> String -> IO ()
> testResults file1 file2 = do 
>   f1 <- readFile file1
>   f2 <- readFile file2
>   case firstDiff f1 f2 of
>     Nothing -> do
>       putStr "Success!\n"
>     Just (cs,ds) -> do
>       putStr "Results differ: '"
>       putStr (take 20 cs)
>       putStr "' vs '"
>       putStr (take 20 ds)
>       putStr "'\n"

Important: The purpose of this assignment is not just to "get the job
done" --- i.e., to produce the right HTML. A more important goal is to
think about what is a good way to do this job, and jobs like it. To
this end, your solution should be organized into two parts:

1. a collection of generic functions for transforming XML structures
   that have nothing to do with plays, plus

2. a short piece of code (a single deﬁnition or a collection of short
   deﬁnitions) that uses the generic functions to do the particular
   job of transforming a play into HTML.

Obviously, there are many ways to do the ﬁrst part. The main challenge
of the assignment is to ﬁnd a clean design that matches the needs of
the second part.

You will be graded not only on correctness (producing the required
output), but also on the elegance of your solution and the clarity and
readability of your code and documentation.  Style counts.  It is
strongly recommended that you rewrite this part of the assignment a
couple of times: get something working, then step back and see if
there is anything you can abstract out or generalize, rewrite it, then
leave it alone for a few hours or overnight and rewrite it again. Try
to use some of the higher-order programming techniques we've been
discussing in class.

Submission Instructions
-----------------------

* If working with a partner, you should both submit your assignments
  individually.
* Make sure your `hw1.lhs` is accepted by GHC without errors or warnings.
* Attach your `hw1.hs` file in an email to `cse230@goto.ucsd.edu` with the
  subject "HW1" (minus the quotes).
  *This address is unmonitored!*

Credits
-------

This homework is essentially Homeworks 1 & 2 from
<a href="http://www.cis.upenn.edu/~bcpierce/courses/552-2008/index.html">UPenn's CIS 552</a>.
