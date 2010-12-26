-----------------------------------------------------------------------------
-- |
-- Module      : Language.JavaScript.LexerUtils 
-- Based on language-python version by Bernie Pope
-- Copyright   : (c) 2009 Bernie Pope 
-- License     : BSD-style
-- Stability   : experimental
-- Portability : ghc
--
-- Various utilities to support the JavaScript lexer. 
-----------------------------------------------------------------------------

module Language.JavaScript.Parser.LexerUtils (
  StartCode
  , Action
  -- , AlexInput  
  -- , alexGetChar  
  -- , alexInputPrevChar  
  , symbolToken  
  , mkString  
  , regExToken  
  , decimalToken  
  -- , endOfLine  
  , endOfFileToken  
  , assignToken  
  , hexIntegerToken  
  , stringToken  
  , lexicalError  
  ) where

import Control.Monad (liftM)
import Control.Monad.Error.Class (throwError)
import Language.JavaScript.Parser.Token as Token 
import Language.JavaScript.Parser.ParserMonad 
import Language.JavaScript.Parser.SrcLocation 
import Prelude hiding (span)

-- Functions for building tokens 

type StartCode = Int
--type Action = AlexSpan -> Int -> String -> P Token 
type Action result = AlexInput -> Int -> result
--type Action = AlexInput -> Int 

{-
endOfLine :: P Token -> Action
endOfLine lexToken span _len _str = do
   setLastEOL $ spanStartPoint span
   lexToken
-}

--symbolToken :: (AlexSpan -> Token) -> Action 
symbolToken mkToken location _ _ = return (mkToken location)
--symbolToken mkToken location = return (mkToken location)

-- special tokens for the end of file and end of line
endOfFileToken :: Token
endOfFileToken = EOFToken alexSpanEmpty
-- dedentToken = DedentToken SpanEmpty 


--mkString :: (AlexSpan -> String -> Token) -> Action
mkString toToken loc len str = do
   return $ toToken loc (take len str)

decimalToken :: AlexSpan -> String -> Token
decimalToken loc str = DecimalToken loc str

hexIntegerToken :: AlexSpan -> String -> Token
hexIntegerToken loc str = HexIntegerToken loc str

assignToken :: AlexSpan -> String -> Token
assignToken loc str = AssignToken loc str

regExToken :: AlexSpan -> String -> Token
regExToken loc str = RegExToken loc str

stringToken :: AlexSpan -> String -> Token
stringToken loc str = StringToken loc str1 delimiter 
  where
    str1 = init $ tail str
    delimiter = head str

-- -----------------------------------------------------------------------------
-- Functionality required by Alex 

-- type AlexInput = (SrcLocation, String)
{-
alexInputPrevChar :: AlexInput -> Char
alexInputPrevChar _ = error "alexInputPrevChar not used"

alexGetChar :: AlexInput -> Maybe (Char, AlexInput)
alexGetChar (loc, input) 
   | null input  = Nothing
   | otherwise = Just (nextChar, (nextLoc, rest))
   where
   nextChar = head input
   rest = tail input 
   nextLoc = moveChar nextChar loc

moveChar :: Char -> SrcLocation -> SrcLocation 
moveChar '\n' = incLine 1 
moveChar '\t' = incTab 
moveChar '\r' = id 
moveChar _    = incColumn 1 
-}

lexicalError :: P a
lexicalError = do
  location <- getLocation
  c <- liftM head getInput
  -- (_,c,_,_) <- getInput
  throwError $ UnexpectedChar c location

{-
readOctNoO :: String -> Integer
readOctNoO (zero:rest) = read (zero:'O':rest)
-}

-- EOF
