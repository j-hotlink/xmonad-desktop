{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
module Desktop
  (
    Desktop.init,
    focusPrev,
    focusNext,
    focusShiftNext,
    focusShiftPrev,
    buildConfig,
    listWorkspaces
  ) where

import XMonad ( X, WorkspaceId, Window, windowset, windows, gets )
import XMonad.StackSet ( currentTag, shiftWin, peek )
import XMonad.Actions.Workscreen ( WorkscreenId, Workscreen( .. ), configWorkscreen, viewWorkscreen )

init :: [ Workscreen ] -> X()
init config =
  configWorkscreen config

buildConfigIndexed :: Int -> [[ String ]] -> [ Workscreen ]
buildConfigIndexed idx []       = []
buildConfigIndexed idx (x:rest) = [ Workscreen { workscreenId = idx, workspaces = x } ]
                                  ++ buildConfigIndexed ( idx + 1 ) rest

buildConfig :: [[ String ]] -> [ Workscreen ]
buildConfig workspaceNames =
  buildConfigIndexed 0 workspaceNames

listWorkspaces :: [ Workscreen ] -> [ WorkspaceId ]
listWorkspaces config =
  foldl (++) [] ( map workspaces config )

lookupFromIndex :: Int -> WorkspaceId -> [ Workscreen ] -> WorkscreenId
lookupFromIndex idx workspaceId []         = 0
lookupFromIndex idx workspaceId ( x:rest )
  | workspaceId `elem` ( workspaces x ) = idx
  | otherwise                           = lookupFromIndex ( idx + 1 ) workspaceId rest

lookupWorkscreenId :: WorkspaceId -> [ Workscreen ] -> WorkscreenId
lookupWorkscreenId = lookupFromIndex 0

currentWorkscreenId :: [ Workscreen ] -> X ( WorkscreenId )
currentWorkscreenId config =
  do
    workspaceid <- gets ( currentTag . windowset )
    return ( lookupWorkscreenId workspaceid config )

getWorkscreen :: [ Workscreen ] -> WorkscreenId -> Workscreen
getWorkscreen config id =
  let found = Prelude.filter (\x -> workscreenId x == id ) config
  in
    case length found of
      1 -> head found          -- return the found element
      _ -> head config        -- return the first defined desktop

currentWorkscreen :: [ Workscreen ] -> X ( Workscreen )
currentWorkscreen config =
  do
    id <- currentWorkscreenId config
    return ( getWorkscreen config id )

currentWindow :: X ( Maybe Window )
currentWindow =
  do
    currentStackSet <- gets windowset
    return ( peek currentStackSet )


focusPrev :: [ Workscreen ] -> X()
focusPrev config =
  do
    desktopid <- currentWorkscreenId config
    let nextdesktopid = desktopid - 1
      in
      if nextdesktopid >= 0
      then
        do
          _ <- viewWorkscreen nextdesktopid
          return ()
      else
        do
          return ()

focusNext :: [ Workscreen ] -> X()
focusNext config =
  do
    desktopid <- currentWorkscreenId config
    let nextdesktopid = desktopid + 1
      in
      if nextdesktopid <= ( ( length config ) - 1 )
      then
        do
          _ <- viewWorkscreen nextdesktopid
          return ()
      else
        do
          return ()

shiftTo :: X () -> X ()
shiftTo refocus =
  do

    -- 1. get the id of the current window with focus
    windowToMove <- currentWindow

    -- 2. switch to the new desktop
    _ <- refocus

    -- 3. move the window to the newly focussed workspace with shiftWin
    case windowToMove of
      Just window ->
        do
          newWsTag <- gets ( currentTag . windowset )
          windows $ \wset -> shiftWin newWsTag window wset
      Nothing ->
        do
          return ()


focusShiftNext :: [ Workscreen ] -> X ()
focusShiftNext config = shiftTo ( focusNext config )

focusShiftPrev :: [ Workscreen ] -> X ()
focusShiftPrev config = shiftTo ( focusPrev config )
