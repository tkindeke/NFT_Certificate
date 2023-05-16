module Main where

import Build_doctests (flags, pkgs, module_sources)
import Data.Foldable (traverse_)
import Test.DocTest

main :: IO ()
main = do
    traverse_ putStrLn args
    doctest args
  where
    args = flags ++ ["-package-db=/nix/store/pl15d7r0mhfpygks2s8cal3jsjivwcl8-ghc-shell-for-openapi3-ghc-8.10.7-env/lib/ghc-8.10.7/package.conf.d"] ++ pkgs ++ module_sources
