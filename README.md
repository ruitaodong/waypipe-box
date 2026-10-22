# waypipe-box

waypipe 0.11 (with `--xwls`), xwayland-satellite and test clients from Ubuntu 26.04,
packaged so an older Ubuntu host (24.04, 22.04, ...) can serve waypipe sessions.
Apps on the host connect through sockets the container creates in shared,
bind-mounted directories.

## Build and install (on the Linux host)

    docker build -t waypipe-box .
    mkdir -p ~/.local/bin
    install -m755 waypipe ~/.local/bin/waypipe

Your user must be able to run `docker` (docker group). For rootless Podman,
build with `podman build -t waypipe-box .` and set
`WAYPIPE_BOX_ENGINE=podman` in `~/.profile`.

Check that SSH login shells pick up the wrapper:

    ssh nano 'bash -lc "command -v waypipe; waypipe --version"'

It should print `~/.local/bin/waypipe` and `waypipe 0.11.0`.

## Use from Wawona

Machine profile settings:

- Xwayland: on (adds `--xwls`)
- Disable GPU: on (no dmabuf; avoids the macOS client's dev_t crash)
- Remote Command: `wp-session foot` to test, or `wp-session` alone to keep a
  session open for host apps

`foot`, `xterm`, `xev` and `wayland-info` run inside the container for testing.

## Run host apps in the session

`wp-session` writes the session's display names to
`$XDG_RUNTIME_DIR/waypipe-session.env`. From any shell on the host:

    . $XDG_RUNTIME_DIR/waypipe-session.env
    xterm &            # X11, via xwayland-satellite in the container
    emacs &            # X11 or pgtk build, whichever the host has

## What is shared and why

| Mount / flag | Needed for |
|---|---|
| `-v /tmp:/tmp` | the `ssh -R` link socket sshd creates on the host, and `/tmp/.X11-unix/X<n>` plus its lock file for host X11 apps |
| `-v $XDG_RUNTIME_DIR` | the Wayland display socket (`wayland-<tag>`) for host Wayland apps |
| `--ipc host` | MIT-SHM shared memory between host X11 apps and Xwayland |
| `--network host` | Xwayland's abstract-namespace X socket |
| `--user` / `--userns=keep-id`, `/etc/passwd` | sockets owned by you, apps that look up your user |
| `-v $HOME` | app configs (foot, Emacs) |

Wayland buffers (memfd) pass between host apps and the container through the
sockets themselves, since both share one kernel.

## Limits

- The session still ends when SSH dies, exactly as with a native waypipe.
- One env file: the most recent session wins if you run several.
