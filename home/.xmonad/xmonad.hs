{-# OPTIONS_GHC -Wno-deprecations #-}

import qualified Data.Map.Strict          as M
import           System.IO
import           XMonad
import           XMonad.Actions.SpawnOn   (spawnOn)
import           XMonad.Config.Desktop
import           XMonad.Config.Kde
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet          as W
import           XMonad.Util.Run          (spawnPipe)
import           XMonad.Hooks.Script (execScriptHook)
import           XMonad.Util.SpawnOnce (spawnOnce)


main = do
  xmproc <- spawnPipe "xmobar"
  xmonad kde4Config
    { modMask = mod4Mask
    , manageHook = manageHook kde4Config
    , startupHook = myStartupHook
    , layoutHook = avoidStruts  $ layoutHook def
    , logHook = dynamicLogWithPP xmobarPP
                    { ppOutput = hPutStrLn xmproc
                    , ppTitle = xmobarColor "black" "" . shorten 50
                    }
    , handleEventHook = handleEventHook kde4Config <+> docksEventHook
    , keys     = kde4Keys <+> keys desktopConfig
    }

kde4Keys (XConfig {modMask = modm}) = M.fromList $
    [ ((modm,               xK_p), spawn  "$(yeganesh -x)")
    , ((modm .|. shiftMask, xK_q), spawn "dbus-send --print-reply --dest=org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout int32:1 int32:0 int32:1")
    ]

   
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "xset r rate 200 50"
  spawnOnce "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)"
  spawnOnce "export EDITOR=emacs"
  spawnOnce "stalonetray &"

