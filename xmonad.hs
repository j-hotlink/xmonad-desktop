-- \
-- {-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances, FlexibleContexts, NoMonomorphismRestriction #-}

--
-- example xmonad config file for multi-monitor setup.
--
import XMonad ( X, ScreenId, XConfig(..), (|||), mod4Mask, spawn, def, xmonad )
import XMonad.Layout ( Mirror(..), Full(..), Tall(..) )
import XMonad.Layout.Tabbed ( simpleTabbed )
import XMonad.Operations ( windows, sendMessage )
import XMonad.Hooks.DebugStack ( debugStackFull )
import XMonad.Actions.CycleWS ( swapPrevScreen )
import XMonad.Hooks.DynamicLog ( PP(..), dynamicLogWithPP, shorten, xmobarPP, xmobarColor, xmobarStrip, dzenEscape )
import XMonad.Util.WorkspaceCompare ( getSortByIndex )
import XMonad.Util.Run ( hPutStrLn )
import XMonad.Hooks.ManageDocks ( docks, avoidStruts, ToggleStruts(..) )
import XMonad.Util.EZConfig ( additionalKeysP )
import XMonad.Util.SpawnOnce ( spawnOnce, spawnOnOnce )
import XMonad.Util.Run ( spawnPipe )
import XMonad.ManageHook ( composeAll, (-->) )
import XMonad.Hooks.FadeWindows ( fadeWindowsEventHook, fadeWindowsLogHook, isUnfocused, transparency, opaque )

import Desktop as Desktop
import Monitor as Monitor

----------------------------------------
--  Theme
----------------------------------------

-- fonts
myFont      = "-*-terminus-medium-*-*-*-*-160-*-*-*-*-*-*"
myWideFont  = "xft:Eurostar Black Extended:"
            ++ "style=Regular:pixelsize=180:hinting=true"

-- colours
base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

-- states
active       = blue
activeWarn   = red
inactive     = base02
focusColor   = blue
unfocusColor = base02

-- sizes
gap         = 10
topbar      = 10
border      = 0
prompt      = 20
status      = 20

--myTerminal            = "xterm"
--myTerminal            = "gnome-terminal"
myTerminal            = "x-terminal-emulator"
myFocusFollowsMouse   = False
myClickJustFocuses    = False
myBorderWidth         = 10
myNormalBorderColor   = "#000000"
myFocusedBorderColor  = active
myModMask            = mod4Mask

-- Monitor screen maps

{-
The next and prev functions define how to move between monitors based on their screenId.
The screen layout is subject to hardware setup and monitor arrangement so these values
need to be adjusted to suit the installation. These support 3 monitors (each maps to a
unique screen) - adjust for more or fewer monitors as needed.
-}
next :: ScreenId -> ScreenId
next 1 = 0
next 0 = 2
next 2 = 2

prev :: ScreenId -> ScreenId
prev 1 = 1
prev 0 = 1
prev 2 = 0

{-
Defines the ordered desktops to use.
Each inner list defines the workspace names that will constitute a single desktop (the
numbers illustrate the designated monitor but any names can be used).
-}
myDesktop = Desktop.buildConfig
  [ 
    [ "personal.0",    "personal.1",   "personal.2"    ],
    [ "company.0",     "company.1",    "company.2"     ],
    [ "projectA.0",    "projectA.1",   "projectA.2"    ],
    [ "projectB.0",    "projectB.1",   "projectB.2"    ],
    [ "projectC.0",    "projectC.1",   "projectC.2"    ]
  ]

myStartupHook =
  do
    Desktop.init myDesktop  -- required to create Xmonad workspaces
    spawnOnce "nitrogen --restore &"
    spawnOnce "compton --config ~/.xmonad/compton/compton.conf &"
    spawnOnce "gnome-terminal -- ~/.xmonad/startup/autostart"
    spawnOnce "~/.dropbox-dist/dropboxd &"

    spawnOnOnce "personal.1" "emacs"
    spawnOnOnce "personal.1" "spotify"
    spawnOnOnce "personal.0" "firefox -p personal"
    spawnOnOnce "personal.2" "gnome-terminal"

    spawnOnOnce "company.1" "emacs"
    spawnOnOnce "company.0" "firefox -p company"
    spawnOnOnce "company.2" "gnome-terminal"

    spawnOnOnce "projectA.1" "emacs"
    spawnOnOnce "projectC.1" "emacs"

----------------------------------------
--  Show workspace name
----------------------------------------
myLayoutHook = avoidStruts ( simpleTabbed ||| tiled ||| Mirror tiled ||| Full )
  where
     tiled   = Tall nmaster delta ratio -- two columns ( left = master, right = slave )
     nmaster = 2                        -- number of windows permitted in master pane
     ratio   = 1/2                      -- initial size of master pane
     delta   = 3/100                    -- how much master pane grows in width each resize

myAdditionalKeysP =
  [ ( "M-S-<Right>",              Monitor.focusShift next )
  , ( "M-S-<Left>",               Monitor.focusShift prev )
  , ( "M-<Right>",                Monitor.focus next )
  , ( "M-<Left>",                 Monitor.focus prev )
  , ( "<XF86AudioMute>",          spawn "amixer -D pulse sset Master toggle" )
  , ( "<XF86AudioLowerVolume>",   spawn "amixer -D pulse sset Master 5%-" )
  , ( "<XF86AudioRaiseVolume>",   spawn "amixer -D pulse sset Master 5%+" )
  , ( "<XF86AudioPlay>",          spawn "playerctl play-pause" )
  , ( "S-<XF86AudioMute>",        spawn "amixer -c 1 sset Speaker toggle" )
  , ( "S-<XF86AudioLowerVolume>", spawn "amixer -c 1 sset Speaker 5%-" )
  , ( "S-<XF86AudioRaiseVolume>", spawn "amixer -c 1 sset Speaker 5%+" )
  , ( "S-<XF86AudioPlay>",        spawn "playerctl play-pause" )
  , ( "M-C-<Page_Up>",            spawn "playerctl previous" )
  , ( "M-C-<Page_Down>",          spawn "playerctl next" )
  , ( "M-C-S-<Page_Up>",          spawn "playerctl position -10" )
  , ( "M-C-S-<Page_Down>",        spawn "playerctl position +10" )

  -- won't work if F-lock is on
  , ( "<Print>",                  spawn "sleep 0.2; gnome-screenshot" )
  , ( "M-C-<Print>",              spawn "sleep 0.2; gnome-screenshot -a" )
  , ( "M-<Print>",                spawn "sleep 0.2; gnome-screenshot" )

  , ( "M-f",                      sendMessage ToggleStruts )
  , ( "M-/",                      do debugStackFull )
  , ( "M-e",                      spawn "emacs" )
  , ( "M-s",                      spawn "gnome-terminal" )
  , ( "M-<Up>",                   Desktop.focusNext myDesktop)
  , ( "M-<Down>",                 Desktop.focusPrev myDesktop)
  , ( "M-S-<Up>",                 Desktop.focusShiftNext myDesktop)
  , ( "M-S-<Down>",               Desktop.focusShiftPrev myDesktop)

  , ( "M--",                      swapPrevScreen )

  ]


myFadeHook = composeAll [ isUnfocused --> transparency 0.5
                        , opaque
                        ]

myManageHook = composeAll [
                          ]

defaults = def {
           -- simple stuff
             terminal           = myTerminal
           , focusFollowsMouse  = myFocusFollowsMouse
           , clickJustFocuses   = myClickJustFocuses
           , borderWidth        = myBorderWidth
           , modMask            = myModMask

           -- required to register initial workspaces at startup
           , XMonad.workspaces  = Desktop.listWorkspaces myDesktop

           , normalBorderColor  = myNormalBorderColor
           , focusedBorderColor = myFocusedBorderColor

           -- hooks, layouts

           , layoutHook         = myLayoutHook
           , logHook            = fadeWindowsLogHook myFadeHook
           , manageHook         = myManageHook

           -- X enhancements : nitrogen (background) and compton (compositor / transparency)
           , startupHook        = myStartupHook
           , handleEventHook    = myHandleEventHook

           }
           `additionalKeysP` myAdditionalKeysP

myHandleEventHook = fadeWindowsEventHook

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"

{-
Shows workspace names using xmobar.
Useful when trying to work out correct screen configuration.
-}
main = do
  xmproc <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobar/xmobar.config"
  --xmonad $ docks defaults
  xmonad $ docks defaults
    {
      logHook = dynamicLogWithPP $ xmobarPP
                { ppCurrent          = xmobarColor xmobarCurrentWorkspaceColor ""
                , ppVisible          = id
                , ppHidden           = const ""
                , ppHiddenNoWindows  = const ""
                , ppVisibleNoWindows = Just id
                , ppUrgent           = id
                , ppSep              = "    "
                , ppWsSep            = " | "
                , ppTitle            = xmobarColor xmobarTitleColor "" . shorten 100
                , ppTitleSanitize    = xmobarStrip . dzenEscape
                , ppLayout           = id
                , ppOrder            = id
                , ppOutput           = hPutStrLn xmproc
                , ppSort             = getSortByIndex
                , ppExtras           = []
               }
    }
