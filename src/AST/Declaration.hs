{-# OPTIONS_GHC -Wall #-}
module AST.Declaration where

import Data.Binary

import qualified AST.Expression.Source as Source
import qualified AST.Expression.Valid as Valid
import qualified AST.Expression.Canonical as Canonical
import qualified AST.Type as Type
import qualified Reporting.Annotation as A



-- DECLARATIONS


data Decl def tipe expr
    = Def def
    | Union String [String] [(String, [tipe])]
    | Alias String [String] tipe
    | Fixity Assoc Int String



-- INFIX STUFF


data Assoc = L | N | R
    deriving (Eq)


assocToString :: Assoc -> String
assocToString assoc =
  case assoc of
    L ->
      "left"

    N ->
      "non"

    R ->
      "right"



-- COMMENTS


data CommentOr a
  = Comment (A.Located String)
  | Whatever a



-- DECLARATION PHASES


type Source =
  CommentOr (A.Located SourceOrDefine)


data SourceOrDefine
  = Source Source'
  | Define String [CommentOr (A.Located Source.Effect)]


type Source' =
  Decl Source.Def Type.Raw Source.Expr


type Valid =
  A.Commented Valid'


type Valid' =
  Decl Valid.Def Type.Raw Valid.Expr


type Canonical =
  A.Commented (Decl Canonical.Def Type.Canonical Canonical.Expr)



-- BINARY CONVERSION


instance Binary Assoc where
    get =
      do  n <- getWord8
          return $ case n of
            0 -> L
            1 -> N
            2 -> R
            _ -> error "Error reading valid associativity from serialized string"

    put assoc =
      putWord8 $
        case assoc of
          L -> 0
          N -> 1
          R -> 2
