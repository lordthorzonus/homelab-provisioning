# Navidrome

Music server at https://navidrome.lan.juusoleinonen.fi, alongside Jellyfin.

- Runs only on nodes labelled `servertype: pc`.
- Mounts `192.168.5.11:/tank/media/library/music` read-only at `/music`.
- Runs as UID/GID 1000, matching the existing media services. The NAS must
  allow this user to read files and traverse directories in the music library.
- Stores its SQLite database and caches in a 10Gi Longhorn volume at `/data`.
  The music files are not copied onto this volume. Transcoding and artwork
  caches are capped at 1GB and 500MB respectively.
- Uses one replica and `Recreate` updates to avoid concurrent database writers.
- Scans hourly as filesystem notifications are unreliable over NFS.

## Storage

10Gi is a starting allocation, not a prediction of actual usage. Monitor the
volume after the first library scan and grow it if needed. This repo configures
two Longhorn replicas, so a full 10Gi volume needs roughly 20Gi across replica
disks, excluding snapshots and overhead. The pod node selector does not constrain
where Longhorn stores replicas.

## Deployment

The homelab ApplicationSet discovers this directory automatically. Pushing these
files to its tracked branch can trigger an automatic ArgoCD deployment.

Before deployment, ensure the hostname resolves to Traefik's address, the PC
nodes can mount the NFS export, and Longhorn has enough free space.

Render locally without contacting the cluster:

```sh
kubectl kustomize kubernetes/media/navidrome
```

Once deployed, open the URL and create the first administrator account promptly.
Back up the `/data` database to preserve users, playlists, favourites and history;
the music library alone does not contain that state.
