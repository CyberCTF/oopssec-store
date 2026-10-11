#!/bin/sh
# The machine's ctf-entrypoint.sh puts the player's flags (CTF_FLAG_<KEY>, given by the launcher)
# in the app and in prisma/flags.ts, from which upstream's entrypoint seeds or upgrades the flags
# table. Two flags were also copied by the first seed into other rows: this init job (run once the
# store answers) copies the current values from the flags table into them, at every start.
cd /app && exec node -e '
const Database = require("better-sqlite3");
const file = process.env.DATABASE_URL.replace(/^file:/, "");
const sleep = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);
let db;
for (let i = 0; ; i++) {
  try {
    db = new Database(file, { fileMustExist: true, timeout: 10000 });
    const n = db.prepare("SELECT count(*) AS n FROM supplier_orders WHERE id = ?").get("sup-ord-lettuce-002").n;
    if (n) break;
  } catch (e) { if (i > 150) throw e; }
  if (db) db.close();
  db = undefined;
  sleep(2000);
}
const flag = (slug) => db.prepare("SELECT flag FROM flags WHERE slug = ?").get(slug).flag;
db.prepare("UPDATE wishlists SET note = ? WHERE id = ?")
  .run(flag("broken-object-level-authorization"), "wl-internal-001");
const row = db.prepare("SELECT notes FROM supplier_orders WHERE id = ?").get("sup-ord-lettuce-002");
db.prepare("UPDATE supplier_orders SET notes = ? WHERE id = ?")
  .run(row.notes.replace(/OSS\{[^}]*\}/g, flag("jwt-algorithm-confusion")), "sup-ord-lettuce-002");
console.log("flags copied into the wishlist and supplier order notes");
'
