{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_openapi3 (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
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
version = Version [3,2,3] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/bin"
libdir     = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/lib"
dynlibdir  = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/lib"
datadir    = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/share"
libexecdir = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/libexec"
sysconfdir = "/home/thierry/.cabal/store/ghc-8.10.7/openapi3-3.2.3-46e0bb974703e635273ed35539d5f8d5df4cf5f84681851d01b5fbaaa123d023/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "openapi3_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "openapi3_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "openapi3_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "openapi3_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "openapi3_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "openapi3_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
