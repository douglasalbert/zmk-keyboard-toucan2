# ZMK config for beekeeb Toucan2 Keyboard

[The beekeeb Toucan2 Keyboard](https://beekeeb.com/introducing-toucan2/) is a wireless split 42-key column‑stagger keyboard that a display and a trackpad, with an aggressive stagger on the pinky columns.

This repo also carries a parallel **Toucan36** variant (`toucan36_left` / `toucan36_right`) for the 36-key column-stagger layout — same trackpad/display hardware, same keymap architecture, minus the two pinky columns.

# Customizations

- **Keymap**: [config/toucan.keymap](config/toucan.keymap) (42-key) / [config/toucan36.keymap](config/toucan36.keymap) (36-key)
- **Combos** (36-key only): [config/combos.dtsi](config/combos.dtsi)
- **General configs**: [boards/shields/toucan/toucan_left.conf](boards/shields/toucan/toucan_left.conf) and [boards/shields/toucan/toucan_right.conf](boards/shields/toucan/toucan_right.conf) (equivalents for the 36-key board live under [boards/shields/toucan36/](boards/shields/toucan36/))
- **Swipe shortcuts**: the `swipe_button_mapper` node in [boards/shields/toucan/toucan.dtsi](boards/shields/toucan/toucan.dtsi)
- **Invert scroll / trackpad settings**: the `tps43_trackpad` node in [boards/shields/toucan/toucan_right.overlay](boards/shields/toucan/toucan_right.overlay)

# Local development

Firmware normally builds via GitHub Actions (`.github/workflows/build.yml`), but a local build/draw environment is also available via Nix + [`just`](https://github.com/casey/just):

```
nix develop        # or `direnv allow` if you use direnv
just init           # one-time: west init + update
just build all       # build every target in build.yaml
just build toucan36  # build targets matching a name
just draw            # render draw/toucan.svg and draw/toucan36.svg from the keymaps
```

The `draw` workflow ([.github/workflows/draw.yml](.github/workflows/draw.yml)) also runs on every push to `main` that touches a keymap, `.dtsi`, or layout `.json`, and commits the regenerated SVGs back under [draw/](draw/).

# License

The code in this repo is available under the MIT license.

The included shield nice_view_gem is modified from https://github.com/M165437/nice-view-gem licensed under the MIT License.

The linked trackpad module is based on https://github.com/geeksville/zmk_driver_azoteq

ZMK code snippets are taken from the ZMK documentation under the MIT license.

The embedded font QuinqueFive is designed by GGBotNet, licensed under under the SIL Open Font License, Version 1.1.
