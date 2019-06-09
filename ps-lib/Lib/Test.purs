module Lib.Test (someString, someForeignString) where

foreign import someForeignString :: String

someString :: String
someString = "Some string from PureScript!"
