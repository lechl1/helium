#!/bin/sh
# Flatpak launcher for Helium.
#
# Runs the prebuilt Helium binary through zypak-wrapper, which makes
# Chromium's namespace/setuid sandbox work inside the Flatpak container by
# proxying it through flatpak-spawn. Mirrors the LD_LIBRARY_PATH setup from
# upstream's helium-wrapper so the bundled libraries are found.

export CHROME_WRAPPER="/app/bin/helium"
export CHROME_VERSION_EXTRA="flatpak"
export LD_LIBRARY_PATH="/app/helium:/app/helium/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# Flatpak provides a writable, persisted HOME under ~/.var/app/net.imput.helium,
# so Helium's profile lives there with no extra flags needed.
exec zypak-wrapper /app/helium/helium "$@"
