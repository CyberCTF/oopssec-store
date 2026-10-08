# OSS OopsSec Store

[OSS OopsSec Store](https://github.com/kOaDT/oss-oopssec-store) by kOaDT and the OopsSec Store
contributors: a deliberately vulnerable e-commerce application built on Next.js, React,
TypeScript and Prisma, with 36 challenges across web, API, authentication, business logic,
cryptography, supply chain, AI agents and MCP. This repository runs it with
[Isoloom](https://www.isoloom.com): [`isoloom.yml`](isoloom.yml) describes the machine, and the
upstream source in [`app/`](app) builds with its own Dockerfile; the database is created and
seeded at first start.

| Machine | Service |
| --- | --- |
| store | OopsSec Store (Next.js) on port 3000 |

## Run it

```bash
isoloom generate
isoloom up docker
```

Then open http://localhost:3000/ (the app's base URL is baked as `http://localhost:3000`, so keep
that port). The lab has no internet: the AI assistant challenges call Mistral's API with a key
the player provides, and the MCP poisoning challenge expects a server on the player's host
(`host.docker.internal`), so those need extra network access. The same spec runs as Docker on a
local VM (`docker-vm`), on a cloud VM (`cloud-docker`) or on Kubernetes. Lab guide: the
[walkthroughs](https://koadt.github.io/oss-oopssec-store).

Upstream version and commit: [UPSTREAM.md](UPSTREAM.md).

## Licence

MIT, as OopsSec Store ([LICENSE](LICENSE)). This application is deliberately vulnerable: keep it
isolated.
