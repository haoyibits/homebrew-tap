# haoyibits/homebrew-tap

Homebrew formulae for [tracebridge and rvdbg](https://github.com/haoyibits/tracebridge)
and a patched OpenOCD for ST Stellar.

```sh
brew install haoyibits/tap/tracebridge
brew install haoyibits/tap/rvdbg            # also installs openocd-stellar
brew install haoyibits/tap/openocd-stellar
```

`Formula/tracebridge.rb` and `Formula/rvdbg.rb` are generated from the latest
tracebridge release by the `Update formulae` workflow (hourly, or run it by
hand from the Actions tab). Do not edit them manually. rvdbg, rustvisor's
debug front end for TRACE32 and StellarLINK, depends on `openocd-stellar`, so
installing it installs the patched OpenOCD too.

`Formula/openocd-stellar.rb` builds
[haoyibits/OpenOCD](https://github.com/haoyibits/OpenOCD/tree/openocd-automotive-mcu-r3)
(ST's `openocd-automotive-mcu-r3` with the SR6P6 flash and reset fixes) from
a release tag. It installs the command as `openocd-stellar`, so it can be
installed next to Homebrew's `open-ocd`. It is edited by hand: bump the tag,
`version` and `sha256` together.
