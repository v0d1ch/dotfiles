
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

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad kde4Config
    { modMask = mod4Mask
    , manageHook = manageHook kde4Config
    , layoutHook = avoidStruts  $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                    { ppOutput = hPutStrLn xmproc
                    , ppTitle = xmobarColor "black" "" . shorten 50
                    }
    , handleEventHook = handleEventHook kde4Config <+> docksEventHook
    , keys     = kde4Keys <+> keys desktopConfig
    , workspaces = myWorkspaces
    , startupHook = do
         spawnOn "www" "google-chrome-stable"
         spawnOn "haskell" "emacs-26.3"
         spawnOn "haskell" "alacritty"
        -- spawnOn "other" "dbeaver"
         spawnOn "mail" "thunderbird"
    }

kde4Keys (XConfig {modMask = modm}) = M.fromList $
    [ ((modm,               xK_p), spawn  "$(yeganesh -x)")
    , ((modm .|. shiftMask, xK_q), spawn "dbus-send --print-reply --dest=org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout int32:1 int32:0 int32:1")
    ]
   
myWorkspaces = ["www", "haskell", "other", "mail" ]
