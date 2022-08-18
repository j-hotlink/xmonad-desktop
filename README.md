# xmonad-desktop

This project supports a multi-monitor and multi-desktop layout for Xmonad (similar to a more traditional gnome multi-desktop layout, but with all the benefits of xmonad).

It allows a large number of open windows to be sanely managed by grouping them into desktops, and preserves their layouts when switching between desktops.

Moving focus or windows between monitors is manged by the functions in Monitor.hs.

Switching between desktops (ie. sets of windows to display across the monitors) and moving windows between them is managed by Desktop.hs.

The sample xmonad.hs provides some useful config that works nicely in this setup:

 * `M-<Left>` and `M-<Right>` move focus left or right between monitors
 * `M-S-<Left>` and `M-S-<Right>` move the focussed window left or right between monitors
 * `M-<Up>` and `M-<Down>` move focus to the desktop above or below.
 * `M-S-<Up>` and `M-S-<Down>` move the focussed window to the desktop above or below.
 * Adds (blue) border to windows to highlight focus (useful on multiple monitors)
 * Uses xmobar to show workspace names of current desktop

![Screenshot - 3 monitors](/assets/images/screenshot-3-monitors.png)

Installation: Place `Monitor.hs` and `Desktop.hs` into your `~/.xmonad/lib/` folder, apply your config and restart xmonad.
