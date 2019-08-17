{-# LANGUAGE RankNTypes      #-}
{-# LANGUAGE TemplateHaskell #-}

{-|

Copyright:
  This file is part of the package zxcvbn-hs. It is subject to the
  license terms in the LICENSE file found in the top-level directory
  of this distribution and at:

    https://code.devalot.com/open/zxcvbn-hs

  No part of this package, including this file, may be copied,
  modified, propagated, or distributed except according to the terms
  contained in the LICENSE file.

License: MIT

-}
module Text.Password.Strength.Internal.Match
  ( Match(..)
  , matchToken
  , matches
  ) where

--------------------------------------------------------------------------------
-- Library Imports:
import Control.Lens (Lens, (^.), (^?), _Left, _Right, _2, views)
import Control.Lens.TH (makePrisms)
import Control.Monad (join)
import Data.Maybe (mapMaybe)
import Data.Text (Text)
import qualified Data.Text as Text

--------------------------------------------------------------------------------
-- Project Imports:
import Text.Password.Strength.Internal.Config
import Text.Password.Strength.Internal.Dictionary
import Text.Password.Strength.Internal.Keyboard
import Text.Password.Strength.Internal.L33t
import Text.Password.Strength.Internal.Token

--------------------------------------------------------------------------------
data Match
  = DictionaryMatch (Rank Token)
    -- ^ 'Token' was found in a frequency dictionary with the
    -- specified rank.

  | ReverseDictionaryMatch (Rank Token)
    -- ^ 'Token' was found in a frequency dictionary, but only after
    -- the entire password was reversed before splitting into tokens.
    -- The token will be in the original order with the original
    -- coordinates.

  | L33tMatch (Rank L33t)
    -- ^ 'Token' was found in a frequency dictionary, but only after
    -- the entire password was translated from l33t speak to English.

  | KeyboardMatch KeyboardPattern

  | BruteForceMatch Token
    -- ^ Used by the scoring system to denote a path that does not
    -- include any of the above matches.

  deriving Show

makePrisms ''Match

--------------------------------------------------------------------------------
matchToken :: Lens Match Match Token Token
matchToken f = go
  where
    go (DictionaryMatch r) = DictionaryMatch <$> (_Rank._2) f r
    go (ReverseDictionaryMatch r) = ReverseDictionaryMatch <$> (_Rank._2) f r
    go (L33tMatch r) = L33tMatch <$> (_Rank._2.l33tToken) f r
    go (KeyboardMatch p) = KeyboardMatch <$> keyboardToken f p
    go (BruteForceMatch t) = BruteForceMatch <$> f t

--------------------------------------------------------------------------------
-- | All possible matches after various transformations.
matches :: Config -> Text -> [Match]
matches config password =
  join [ DictionaryMatch <$> lookR dict
       , ReverseDictionaryMatch <$> rdict
       , L33tMatch <$> l33ts
       , KeyboardMatch <$> keyboard
       , BruteForceMatch <$> brutes
       ]
  where
    lookR :: [Lookup a] -> [Rank a]
    lookR = mapMaybe (^? _Right)

    dict :: [Lookup Token]
    dict = rankFromAll config (^. tokenChars) (allTokens password)

    nonDict :: [Token]
    nonDict = mapMaybe (^? _Left) dict

    rdict :: [Rank Token]
    rdict = lookR $ rankFromAll config (views tokenChars Text.reverse) nonDict

    l33ts :: [Rank L33t]
    l33ts = lookR $ rankFromAll config (^. l33tText) (concatMap l33t nonDict)

    keyboard :: [KeyboardPattern]
    keyboard = concatMap (\g -> mapMaybe (keyboardPattern g) nonDict)
                         (config ^. keyboardGraphs)

    -- Brute force matches are tokens that were not matched some other way.
    brutes :: [Token]
    brutes = nonDict
               -- `intersect` map (^. _Rank._2) rdict
               -- `intersect` map (^. _Rank._2.l33tToken) l33ts