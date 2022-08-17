module Monitor
  (
    focus,
    focusShift
  )
  where

import XMonad ( X, ScreenId, screenWorkspace, windows )
import XMonad.StackSet ( shift, view )
import XMonad.Actions.CycleWS ( screenBy )

focus :: ( ScreenId -> ScreenId ) -> X ()
focus adjacency =
  do s <- screenBy 0
     cws <- screenWorkspace s
     mws <- screenWorkspace ( adjacency s )
     case mws of
       Nothing -> return ()
       Just ws ->
         if cws == mws then
           do
             s <- screenBy 0
             return ()
         else
           do
             result <- windows ( view ws )
             return ()

focusShift :: ( ScreenId -> ScreenId ) -> X ()
focusShift adjacency =
  do s <- screenBy 0
     cws <- screenWorkspace s
     mws <- screenWorkspace ( adjacency s )
     case mws of
       Nothing -> return ()
       Just ws ->
         if cws == mws then
           return ()
         else
           windows ( shift ws )
     focus adjacency
