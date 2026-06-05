# Helium Flatpak

A Flatpak wrapper for the [Helium](https://github.com/imputnet/helium) browser.
It repackages the official prebuilt Linux tarballs from
[`helium-linux`](https://github.com/imputnet/helium-linux) releases — it does
**not** rebuild Chromium from source.

The packaging follows the same approach as the Flathub
[Brave manifest](https://github.com/flathub/com.brave.Browser): the
`org.chromium.Chromium.BaseApp` base, [zypak](https://github.com/refi64/zypak)
for the sandbox, and `dconf` for proxy resolution. The sandbox permissions in
`finish-args` are adapted directly from Brave's, since Helium is also a
Chromium fork with the same host-integration needs.

## Files

| File | Purpose |
| --- | --- |
| `net.imput.helium.yaml` | Flatpak manifest |
| `helium.sh` | In-sandbox launcher (runs the binary via `zypak-wrapper`) |
| `net.imput.helium.metainfo.xml` | AppStream metadata |
| `dconf-override.patch` | Lets dconf honour `DCONF_USER_CONFIG_DIR` |

## Build & install

Requires `flatpak` and `flatpak-builder`.

```sh
# One-time: Flathub remote + runtime/SDK/base-app
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.freedesktop.Platform//25.08 \
                                org.freedesktop.Sdk//25.08 \
                                org.chromium.Chromium.BaseApp//25.08

# Build and install into the user installation
flatpak-builder --user --install --force-clean build-dir flatpak/net.imput.helium.yaml

# Run
flatpak run net.imput.helium
```

## Updating to a new Helium release

1. Bump the version in the two `url:` lines (and `releases` in the metainfo).
2. Replace both `sha256:` values. The digests are published on the release —
   no need to download the tarballs:

   ```sh
   gh api repos/imputnet/helium-linux/releases/tags/<VERSION> \
     --jq '.assets[] | select(.name|test("linux\\.tar\\.xz$")) | "\(.name) \(.digest)"'
   ```

## Notes

- **Architectures:** `x86_64` and `aarch64`, matching upstream's tarballs.
- **MPRIS / media keys:** Helium (ungoogled-chromium) registers under the
  `org.mpris.MediaPlayer2.chromium.*` bus name; the manifest owns both that and
  a `helium.*` variant. Adjust `--own-name` if media keys don't bind.
- **Host policies:** managed-policy JSON is read from `/etc/helium/policies` on
  the host (via `--filesystem=host-etc`).
