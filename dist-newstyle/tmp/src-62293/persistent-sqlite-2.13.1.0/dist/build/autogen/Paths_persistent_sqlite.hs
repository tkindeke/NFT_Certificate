{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_persistent_sqlite (
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
version = Version [2,13,1,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/bin"
libdir     = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/lib"
dynlibdir  = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/lib"
datadir    = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/share"
libexecdir = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/libexec"
sysconfdir = "/home/thierry/.cabal/store/ghc-8.10.7/persistent-sqlite-2.13.1.0-79d15b366d3d0cd13ec52413bf93fd662e296c5bec3cff40411b11d75d0d9b2d/etc"

getBinDir     = catchIO (getEnv "persistent_sqlite_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "persistent_sqlite_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "persistent_sqlite_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "persistent_sqlite_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "persistent_sqlite_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "persistent_sqlite_sysconfdir") (\_ -> return sysconfdir)




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
