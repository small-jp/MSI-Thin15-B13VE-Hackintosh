#!/bin/bash
# Daily-use smoothness tweaks for macOS Tahoe on the WhateverXe iGPU path.
# They lower WindowServer's per-frame GPU job count (blur / Liquid Glass / animations),
# which is the bottleneck on the -disablegfxfirmware host-scheduler path.
# Run:   bash tahoe-smooth.sh          (apply)
#        bash tahoe-smooth.sh undo     (revert)
# Terminal may need Full Disk Access (System Settings > Privacy & Security) for the
# Accessibility writes; if they fail, toggle them by hand in System Settings > Accessibility > Display.
set -u
v=true; [ "${1:-}" = undo ] && v=false

ok(){ echo "  ok   $1"; }; bad(){ echo "  FAIL $1 -> set it by hand in System Settings"; }
w(){ defaults write "$@" 2>/dev/null; }

echo "Accessibility:"
# Reduce Transparency removes Liquid Glass (opaque Dock). Off by default; run with "glass-off" to enable it.
[ "${1:-}" = glass-off ] && { w com.apple.universalaccess reduceTransparency -bool true && ok "Reduce Transparency=true" || bad "Reduce Transparency"; }
[ $v = false ] && w com.apple.universalaccess reduceTransparency -bool false
w com.apple.universalaccess reduceMotion       -bool $v && ok "Reduce Motion=$v"       || bad "Reduce Motion"

echo "Dock / windows / Mission Control:"
if [ $v = true ]; then
  w com.apple.dock launchanim -bool false
  w com.apple.dock mineffect -string scale
  w com.apple.dock expose-animation-duration -float 0.1
  w NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
  w NSGlobalDomain NSWindowResizeTime -float 0.001
else
  defaults delete com.apple.dock launchanim 2>/dev/null
  defaults delete com.apple.dock mineffect 2>/dev/null
  defaults delete com.apple.dock expose-animation-duration 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null
  defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null
fi
ok "animations $( [ $v = true ] && echo reduced || echo restored )"

echo "WindowManager (desktop widgets / Stage Manager / click-to-show-desktop):"
for k in StandardHideWidgets StageManagerHideWidgets; do
  [ $v = true ] && w com.apple.WindowManager $k -bool true || defaults delete com.apple.WindowManager $k 2>/dev/null; done
if [ $v = true ]; then w com.apple.WindowManager GloballyEnabled -bool false; w com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
else defaults delete com.apple.WindowManager GloballyEnabled 2>/dev/null; defaults delete com.apple.WindowManager EnableStandardClickToShowDesktop 2>/dev/null; fi
killall WindowManager 2>/dev/null; ok "WindowManager $( [ $v = true ] && echo trimmed || echo restored )"

echo "Power (needs sudo): Low Power Mode off - the CPU drives GPU submission here"
[ $v = true ] && sudo pmset -a lowpowermode 0 && ok "lowpowermode 0"

killall Dock 2>/dev/null; killall SystemUIServer 2>/dev/null
echo
echo "Spotlight indexing status (heavy CPU after a fresh install also adds lag; let it finish):"
mdutil -s / 2>/dev/null
echo
echo "Manual, recommended: System Settings > Displays > Refresh Rate = 60 Hz,"
echo "and Appearance > Liquid Glass = Tinted (if present). Log out/in once."
