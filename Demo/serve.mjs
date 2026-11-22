import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "..");
const port = Number(process.argv[2] || 4177);
const mime = { ".html":"text/html; charset=utf-8", ".css":"text/css; charset=utf-8", ".js":"text/javascript; charset=utf-8", ".mjs":"text/javascript; charset=utf-8", ".png":"image/png", ".wav":"audio/wav", ".json":"application/json; charset=utf-8" };
http.createServer((req, res) => {
  const requestPath = decodeURIComponent((req.url || "/").split("?")[0]);
  let file = path.join(root, requestPath);
  if (!file.startsWith(root)) { res.writeHead(403); res.end("Forbidden"); return; }
  try {
    if (fs.statSync(file).isDirectory()) file = path.join(file, "index.html");
  } catch {
    res.writeHead(404); res.end("Not found"); return;
  }
  fs.readFile(file, (error, data) => {
    if (error) { res.writeHead(404); res.end("Not found"); return; }
    res.writeHead(200, { "Content-Type": mime[path.extname(file)] || "application/octet-stream", "Cache-Control": "no-store", "Content-Length": data.length });
    res.end(data);
  });
}).listen(port, "127.0.0.1", () => console.log(`MellowMind demo: http://127.0.0.1:${port}/Demo/`));
