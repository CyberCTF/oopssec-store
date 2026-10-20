# Upstream's Dockerfile (app/Dockerfile), unchanged, built from app/, followed by the CyberCTF
# per-player flags overlay (the vendored source is unchanged; the overlay's files are inlined).
# Keep this default in sync with .nvmrc; tests/unit/node-version-parity.test.ts
# fails the build if they drift.
ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package*.json ./
# Cypress runs on the host against the container, never inside it: skip the
# binary its postinstall would otherwise download.
RUN CYPRESS_INSTALL_BINARY=0 npm ci && npm cache clean --force

COPY . .

# Prisma v6 requires DATABASE_URL even during generate; use a throwaway value
RUN DATABASE_URL=file:/tmp/build.db npx prisma generate

# Provide a temporary database so Next.js can complete the build
# (server components may query the DB during static analysis)
RUN DATABASE_URL=file:/tmp/build.db npx prisma db push --skip-generate

ENV NEXT_TELEMETRY_DISABLED=1
RUN DATABASE_URL=file:/tmp/build.db npm run build

# The entrypoint seeds through tsx, and both the seed and the Prisma config
# load dotenv: they are runtime dependencies, so the prune must keep them.
RUN npm prune --omit=dev \
  && rm -rf .next/cache /tmp/build.db \
  && chmod +x docker-entrypoint.sh

FROM node:${NODE_VERSION}-alpine

WORKDIR /app

COPY --from=builder /app /app

RUN mkdir -p /app/data /app/uploads /app/documents/invoices /app/logs

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV DATABASE_URL=file:/app/data/dev.db
ENV PARTNER_SIGNING_KEY_PATH=/app/data/partner-signing-key.pem
ENV NEXT_PUBLIC_BASE_URL=http://localhost:3000

EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]

# CyberCTF per-player flags. Upstream's OSS{...} flags stay as the development values. At build,
# every file of the image that holds one of them (the compiled routes and pages, prisma/flags.ts
# that seeds and upgrades the flags table, flag.txt, flag-xxe.txt, .env.local, the files under
# public/ and lab/) is listed and a pristine copy kept. ctf-entrypoint.sh restores those copies at
# every start and writes the player's flags (CTF_FLAG_<KEY>) in place of upstream's, then runs
# upstream's entrypoint, which seeds or upgrades the database from prisma/flags.ts. ctf/flag.sh
# (the init job) then copies the two flags the seed also wrote into other rows (a wishlist note,
# a supplier order note) from the flags table.
COPY <<'TSV' /usr/local/share/ctf/flags.tsv
main	OSS{r3act2sh3ll}
public-env-variable	OSS{public_3nvir0nment_v4ri4bl3}
weak-jwt-secret	OSS{w34k_jwt_s3cr3t_k3y}
client-side-price-manipulation	OSS{cl13nt_s1d3_pr1c3_m4n1pul4t10n}
weak-md5-hashing	OSS{w34k_md5_h4sh1ng}
insecure-direct-object-reference	OSS{1ns3cur3_d1r3ct_0bj3ct_r3f3r3nc3}
cross-site-scripting-xss	OSS{cr0ss_s1t3_scr1pt1ng_xss}
cross-site-request-forgery	OSS{cr0ss_s1t3_r3qu3st_f0rg3ry}
mass-assignment	OSS{m4ss_4ss1gnm3nt_vuln3r4b1l1ty}
path-traversal	OSS{p4th_tr4v3rs4l_4tt4ck}
server-side-request-forgery	OSS{s3rv3r_s1d3_r3qu3st_f0rg3ry}
sql-injection	OSS{sql_1nj3ct10n_vuln3r4b1l1ty}
information-disclosure-api-error	OSS{1nf0_d1scl0sur3_4p1_3rr0r}
malicious-file-upload	OSS{m4l1c10us_f1l3_upl04d_xss}
product-search-sql-injection	OSS{pr0duct_s34rch_sql_1nj3ct10n}
session-fixation-weak-session-management	OSS{s3ss10n_f1x4t10n_4tt4ck}
brute-force-no-rate-limiting	OSS{brut3_f0rc3_n0_r4t3_l1m1t}
x-forwarded-for-sql-injection	OSS{x_f0rw4rd3d_f0r_sql1}
prompt-injection-ai-assistant	OSS{pr0mpt_1nj3ct10n_41_4ss1st4nt}
broken-object-level-authorization	OSS{brok3n_0bj3ct_l3v3l_4uth0r1z4t10n}
broken-function-level-authorization	OSS{brok3n_funct10n_l3v3l_4uth0r1z4t10n}
second-order-sql-injection	OSS{s3c0nd_0rd3r_sql_1nj3ct10n}
plaintext-password-in-logs	OSS{pl41nt3xt_p4ssw0rd_1n_l0gs}
xxe-supplier-order-import	OSS{xml_3xt3rn4l_3nt1ty_1nj3ct10n}
insecure-password-reset	OSS{1ns3cur3_p4ssw0rd_r3s3t}
open-redirect	OSS{0p3n_r3d1r3ct_l0g1n_byp4ss}
self-xss-profile-injection	OSS{s3lf_xss_pr0f1l3_1nj3ct10n}
csrf-profile-takeover-chain	OSS{csrf_pr0f1l3_t4k30v3r_ch41n}
aes-cbc-padding-oracle	OSS{p4dd1ng_0r4cl3_f0rg3d_t0k3n}
mcp-malicious-server	OSS{mcp_p01s0n3d_t00l_r3sp0ns3}
middleware-authorization-bypass	OSS{m1ddl3w4r3_byp4ss}
race-condition-coupon-abuse	OSS{r4c3_c0nd1t10n_c0up0n_4bus3}
insecure-randomness-gift-card	OSS{1ns3cur3_r4nd0mn3ss_g1ft_c4rd}
npm-supply-chain-typosquat	OSS{npm_typ0sqv4tt1ng_dr0p_4i_rul3s}
ai-rules-file-backdoor	OSS{rul3s_f1l3_b4ckd00r_3xpl01t3d}
jwt-algorithm-confusion	OSS{jwt_4lg_c0nfus10n}
TSV
COPY --chmod=755 <<'SH' /usr/local/bin/ctf-entrypoint.sh
#!/bin/sh
# CyberCTF per-player flags (see the Dockerfile). Each flag comes from CTF_FLAG_<KEY> (given by
# the launcher), else upstream's. No copy is kept in a file: the path traversal challenges would
# read it.
set -e
share=/usr/local/share/ctf
script=$(mktemp)
b64() { printf '%s' "$1" | base64 | tr -d '\n'; }
while IFS="$(printf '\t')" read -r key upstream; do
  [ -n "$key" ] || continue
  var=CTF_FLAG_$(printf '%s' "$key" | tr 'a-z-' 'A-Z_')
  eval "flag=\${$var:-}"
  [ -n "$flag" ] || flag=$upstream
  unset "$var"
  [ "$flag" = "$upstream" ] && continue
  printf 's|%s|%s|g\n' "$upstream" "$flag" >> "$script"
  # The public environment variable flag is inlined base64-encoded in the client bundle.
  printf 's|%s|%s|g\n' "$(b64 "$upstream")" "$(b64 "$flag")" >> "$script"
done < "$share/flags.tsv"
while read -r f; do
  cp -p "$share/pristine$f" "$f"
  [ -s "$script" ] && sed -i -f "$script" "$f"
done < "$share/files"
rm -f "$script"
exec ./docker-entrypoint.sh "$@"
SH
RUN share=/usr/local/share/ctf \
 && cut -f2 "$share/flags.tsv" > /tmp/needles \
 && cut -f2 "$share/flags.tsv" | while read -r v; do printf '%s' "$v" | base64 | tr -d '\n'; echo; done >> /tmp/needles \
 && find /app \( -path /app/node_modules -o -path /app/data -o -path /app/uploads \
      -o -path /app/documents -o -path /app/logs \) -prune \
      -o -type f -exec grep -lF -f /tmp/needles {} + | sort > "$share/files" \
 && while read -r f; do mkdir -p "$share/pristine$(dirname "$f")" && cp -p "$f" "$share/pristine$f"; done < "$share/files" \
 && rm -f /tmp/needles && echo "files holding a flag: $(wc -l < "$share/files")" \
 && test -s "$share/files"
ENTRYPOINT ["/usr/local/bin/ctf-entrypoint.sh"]
