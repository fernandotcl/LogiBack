# LogiBack

A minimal macOS command line tool that maps the thumb buttons on a mouse (such as the Logitech MX Vertical) to back and forward, so you don't need Logi Options.

- Back button → ⌘[
- Forward button → ⌘]

The original button clicks are swallowed. All other buttons are left alone.

## Install

Quit or uninstall Logi Options first, since it intercepts the buttons.

```
make install
```

This builds the tool, copies it to `~/bin/logiback`, and installs a LaunchAgent that starts it at login.

Then grant Accessibility permission to `~/bin/logiback` in System Settings › Privacy & Security › Accessibility, and restart it:

```
launchctl kickstart -k gui/$(id -u)/com.fernandotcl.logiback
```

## Uninstall

```
make uninstall
```

## Troubleshooting

- Check that it's running: `launchctl print gui/$(id -u)/com.fernandotcl.logiback`
- Run `~/bin/logiback` from a terminal to see whether it reports a missing permission.
- After rebuilding, macOS may stop trusting the binary. Remove it from the Accessibility list and add it again.
- The shortcuts are sent using the physical key positions of `[` and `]` on a US keyboard. On other keyboard layouts they may not trigger.
