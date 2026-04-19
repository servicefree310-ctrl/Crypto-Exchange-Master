const http = require('http');
const fs = require('fs');
const path = require('path');
const PORT = parseInt(process.env.PORT || '8082', 10);
const BASE = (process.env.BASE_PATH || '/flutter/').replace(/\/+$/, '');
const ROOT = path.resolve(__dirname, '..', 'build', 'web');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.otf': 'font/otf',
  '.wasm': 'application/wasm',
  '.map': 'application/json',
  '.bin': 'application/octet-stream',
};

const server = http.createServer((req, res) => {
  let urlPath = decodeURIComponent(req.url.split('?')[0]);
  if (BASE && urlPath.startsWith(BASE)) urlPath = urlPath.slice(BASE.length) || '/';
  if (urlPath === '/' || urlPath === '') urlPath = '/index.html';

  const filePath = path.join(ROOT, urlPath);
  if (!filePath.startsWith(ROOT)) { res.writeHead(403); return res.end('forbidden'); }

  fs.stat(filePath, (err, stat) => {
    let target = filePath;
    if (err || stat.isDirectory()) target = path.join(ROOT, 'index.html');
    fs.readFile(target, (e, data) => {
      if (e) { res.writeHead(404); return res.end('not found'); }
      const ext = path.extname(target).toLowerCase();
      res.writeHead(200, {
        'Content-Type': MIME[ext] || 'application/octet-stream',
        'Cache-Control': 'no-store',
        'Cross-Origin-Opener-Policy': 'same-origin',
        'Cross-Origin-Embedder-Policy': 'credentialless',
      });
      res.end(data);
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Serving ${ROOT} on 0.0.0.0:${PORT} under ${BASE}/`);
});
