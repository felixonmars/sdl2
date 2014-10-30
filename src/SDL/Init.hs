{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
module SDL.Init
  ( initialize
  , initializeSubSystem
  , InitFlag(..)
  , quit
  , version
  ) where

import Data.Bitmask (foldFlags)
import Data.Foldable
import Data.Typeable
import Foreign
import SDL.Internal.Numbered

import qualified SDL.Exception as SDLEx
import qualified SDL.Raw as Raw

data InitFlag
  = InitTimer
  | InitAudio
  | InitVideo
  | InitJoystick
  | InitHaptic
  | InitGameController
  | InitEvents
  | InitEverything
  | InitNoParachute
  deriving (Eq, Show, Typeable)

instance ToNumber InitFlag Word32 where
  toNumber InitTimer = Raw.SDL_INIT_TIMER
  toNumber InitAudio = Raw.SDL_INIT_AUDIO
  toNumber InitVideo = Raw.SDL_INIT_VIDEO
  toNumber InitJoystick = Raw.SDL_INIT_JOYSTICK
  toNumber InitHaptic = Raw.SDL_INIT_HAPTIC
  toNumber InitGameController = Raw.SDL_INIT_GAMECONTROLLER
  toNumber InitEvents = Raw.SDL_INIT_EVENTS
  toNumber InitEverything = Raw.SDL_INIT_EVERYTHING
  toNumber InitNoParachute = Raw.SDL_INIT_NOPARACHUTE

-- | Initializes SDL and the given subsystems. Do not call any SDL functions
-- prior to this one, unless otherwise documented that you may do so.
--
-- Throws 'SDLEx.SDLException' if initialization fails.
initialize :: Foldable f => f InitFlag -> IO ()
initialize flags =
  SDLEx.throwIfNeg_ "SDL.Init.init" "SDL_Init" $
    Raw.init (foldFlags toNumber flags)

-- | Initialize individual subsystems. SDL needs to be initializied prior
-- to calls to this function.
--
-- Throws 'SDLEx.SDLException' if initialization fails.
initializeSubSystem :: Foldable f => f InitFlag -> IO ()
initializeSubSystem flags =
  SDLEx.throwIfNeg_ "SDL.Init.initSubSystem" "SDL_InitSubSystem" $
    Raw.initSubSystem (foldFlags toNumber flags)

-- | Quit and shutdown SDL, freeing any resources that may have been in use.
-- Do not call any SDL functions after you've called this function, unless
-- otherwise documented that you may do so.
quit :: IO ()
quit = Raw.quit

-- | The major, minor, and patch versions of the SDL library linked with.
-- Does not require initialization.
version :: Integral a => IO (a, a, a)
version = do
	Raw.Version major minor patch <- alloca $ \v -> Raw.getVersion v >> peek v
	return (fromIntegral major, fromIntegral minor, fromIntegral patch)