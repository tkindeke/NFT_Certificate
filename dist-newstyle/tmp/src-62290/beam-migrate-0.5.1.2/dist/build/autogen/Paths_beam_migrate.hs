{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_beam_migrate (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,5,1,2] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/bin"
libdir     = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/lib"
dynlibdir  = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/lib"
datadir    = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/share"
libexecdir = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/libexec"
sysconfdir = "/home/thierry/.cabal/store/ghc-8.10.7/beam-migrate-0.5.1.2-6c5d8dc4d74224dc7df884f05e65853c43cb792a57d53be0e4422acf7531f1bc/etc"

getBinDir     = catchIO (getEnv "beam_migrate_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "beam_migrate_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "beam_migrate_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "beam_migrate_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "beam_migrate_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "beam_migrate_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
