# Upstream

| | |
| --- | --- |
| Project | OSS OopsSec Store |
| Repository | https://github.com/kOaDT/oss-oopssec-store |
| Version | v2.22.0 |
| Commit | 735fa4c0ce3140aec271841aa69d32443f279fbb |
| Licence | MIT |

`app/` is that release, unchanged, without its Git history, built by its own Dockerfile
(`node:22-alpine`, `npm ci` from the lockfile). Its `docker-entrypoint.sh` creates and seeds the
SQLite database on first start; the spec keeps `/app/data`, `/app/uploads` and
`/app/documents` in volumes as upstream's `docker-compose.yml` does. Not reproduced from that
compose file: the `host.docker.internal` host entry for the MCP poisoning challenge. To update,
replace `app/` with a newer release, then change this table.
