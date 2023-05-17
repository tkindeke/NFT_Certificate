{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_set_algebra (
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
bindir     = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/bin"
libdir     = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/lib"
dynlibdir  = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/lib"
datadir    = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/share"
libexecdir = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/libexec"
sysconfdir = "/home/thierry/.cabal/store/ghc-8.10.7/set-algebra-0.1.0.0-05cdc2c8ac8fc9e361742a59aeae718afe192a3ce724261e472809985f9484f8/etc"

getBinDir     = catchIO (getEnv "set_algebra_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "set_algebra_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "set_algebra_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "set_algebra_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "set_algebra_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "set_algebra_sysconfdir") (\_ -> return sysconfdir)




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
