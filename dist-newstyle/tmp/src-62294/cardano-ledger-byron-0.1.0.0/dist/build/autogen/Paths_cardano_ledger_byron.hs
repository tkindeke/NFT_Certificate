{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_cardano_ledger_byron (
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
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/bin"
libdir     = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/lib"
dynlibdir  = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/lib"
datadir    = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/share"
libexecdir = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/libexec"
sysconfdir = "/home/thierry/.cabal/store/ghc-8.10.7/cardano-ledger-byron-0.1.0.0-0ce9d6c1f48ddc93b49b41f95d046eb3a6c5303f0e50e3d1230c1b988f31118e/etc"

getBinDir     = catchIO (getEnv "cardano_ledger_byron_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "cardano_ledger_byron_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "cardano_ledger_byron_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "cardano_ledger_byron_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "cardano_ledger_byron_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "cardano_ledger_byron_sysconfdir") (\_ -> return sysconfdir)




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
