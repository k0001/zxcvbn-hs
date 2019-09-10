-- This file is automatically generated, DO NOT EDIT!
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Text.Password.Strength.Generated.Adjacency where
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.Text (Text)
import qualified Codec.Compression.GZip as GZip
import qualified Data.ByteString.Base64.Lazy as Base64
import qualified Data.Binary as Binary
import Data.Binary.Orphans ()
import Text.Password.Strength.Types

qwerty :: AdjacencyTable
qwerty =
  let decode = Binary.decode . GZip.decompress . Base64.decodeLenient
  in  decode "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"

numpad :: AdjacencyTable
numpad =
  let decode = Binary.decode . GZip.decompress . Base64.decodeLenient
  in  decode "H4sIAAAAAAAAAy2OyXEAIQwE8f10HlBcAgkpGOefhum19zGr0vSMSOn5vv9+6eP//5PzS0q5pLerNb1e7enzqoPkSO8plZy+rpYLlkqoLMxijwZ4zY8W8FovWAOztTu2gdeEkrbI98yh3q/ZD1x3gj14xWiYY1xzTOghiXmhc4DMyShwc4NMxZSGKYMumRwVYb0AZXNfFFwMfJVHG/gaPGMJobVYK/gy8D1BttC+9zW30rjPYzotOsmrAOoC1E2XKqaB66FRnZAGIXseYELUFlFTQmasHdwC/HTAs0GO0n4OC6fXM6Z3QN90uQK6Afqh0R0kwCMDRnnmSjQ6l0KJhhENJxRxzV/6iRjqNwIAAA=="

