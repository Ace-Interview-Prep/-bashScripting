{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-} 

module Main where

import System.Process

import Data.Foldable
import Text.Printf

import Data.List
import qualified Data.ByteString as B
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Lazy as LB
  
import Graphics.Matplotlib
import System.Which (staticWhichNix, staticWhich)
import Data.Text (Text, pack, unpack)

import Shelly
import System.FilePath 

import Data.Time.Clock 

ffmpeg' = $(staticWhich "ffmpeg")


main = do
  shelly shellyScript
  
  -- runCommand "ls"
  
  -- runCommand "cat makeMusic.cabal"
  
  -- runCommand $ printf "ffplay -showmode 1 -f f32le -ar %f %s" sampleRate outputFilePath -- trick


{- ffmpeg -i 'A Revelation of Space _ David Korins _ TEDxBroadway.webm' test.wav -} 

newBase = "ted-wavey"


shellyScript :: Sh ()
shellyScript = do
  tedEvents <- ls "/mount/passport/AAAA_TED"

  -- lets also ensure that the new base exists 
  
  mapM_ processDir tedEvents
  --liftIO $ mapM_ print $ head tedTalks

  -- let example = head $ head tedTalks

  -- liftIO $ mapM_ print $ splitPath example

  -- for dir 

-- | We will also need to create the new directory for the event 
processDir :: FilePath -> Sh ()
processDir pathToTedEvent = do
  
  videoPaths <- ls pathToTedEvent
  
  -- TODO(galen): dont use last
  let tedEventONLY = last $ splitPath pathToTedEvent
  let newDirPath = "/mount/passport/" <> newBase <> "/" <> (pack tedEventONLY)

  run_ "mkdir" ["-p", newDirPath]

  videos <- ls pathToTedEvent
  mapM_ (\videoPath -> ffmpeg videoPath (newWavPath newDirPath videoPath)) $ videos
  

newWavPath :: Text -> FilePath -> FilePath 
newWavPath newDirPath oldpath = (unpack newDirPath) <> "/" <> (f . last $ splitPath oldpath)
  where
    f :: FilePath -> FilePath
    f file = replaceExtensions file ".wav"
  
-- | Take the old one and just replace it with the new base
  

ffmpeg :: FilePath -> FilePath -> Sh () 
ffmpeg from to = run_ ffmpeg' ["-i",pack from, pack to] 

  -- of example, last is file, second last is event, third is AAAA_TED
  -- we only want to replace the third last

  -- we also want to do this with ffmpeg 
  
--  liftIO $ mapM_ print tedEvents
