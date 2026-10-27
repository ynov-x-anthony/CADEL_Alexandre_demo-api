'use strict';

/*
 * notifier - service independant : recoit une notification d'api et la logge
 * (simulateur d'email/Slack). Aucune dependance : module http natif.
 *
 * Variables d'environnement :
 *   PORT   port d'ecoute   (def: 4000)
 */

const http = require('http');

const PORT = Number(process.env.PORT || 4000);

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    return send(res, 200, { status: 'UP' });
  }

  if (req.method === 'POST' && req.url === '/notify') {
    let raw = '';
    req.on('data', (chunk) => {
      raw += chunk;
      if (raw.length > 1e5) req.destroy();
    });
    req.on('end', () => {
      console.log(`[notifier] nouveau produit : ${raw}`);
      send(res, 202, { received: true });
    });
    return;
  }

  send(res, 404, { error: 'not_found' });
});

server.listen(PORT, () => {
  console.log(JSON.stringify({ level: 'info', msg: 'notifier started', port: PORT }));
});

// PID 1 : arret propre sur SIGTERM (sinon "docker stop" attend 10 s puis SIGKILL).
function shutdown(sig) {
  console.log(JSON.stringify({ level: 'info', msg: 'shutting down', sig }));
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 8000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
