const express = require('express');
const { appendFile } = require('fs');
const WebSocket = require("ws");
const { createServer } = require('http');

const server = createServer();

const app = express();
app.use(express.json());

server.listen(4001, () => console.log('server is listening on port 4001 (WS).'));

const wss = new WebSocket.WebSocketServer({ noServer: true });

server.on('upgrade', function upgrade(request, socket, head) {
    console.log('incoming upgrade request...');
    wss.handleUpgrade(request, socket, head, function done(ws) {
      wss.emit('connection', ws, request);
    });
});


// const wss = new WebSocket.Server({ port: 4001 });
wss.on("connection", function connection(ws) {
  ws.on("message", function incoming(message, isBinary) {
    console.log(message.toString(), isBinary);
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });
});

app.use((req, res, next) => {
  console.log('Time: ', Date.now());
  next();
});

app.use('/request-type', (req, res, next) => {
  console.log('Request type: ', req.method);
  next();
});

app.get('/', (req, res) => {
  console.log('response.', req.body);
  res.send('Successful response.');
});

app.post('/', (req, res) => {
  console.log('response body', req.body);
  // append json data into csv file
  const { sample_type, value, unit } = JSON.parse(JSON.stringify(req.body));
  appendFile('data.jsonl', JSON.stringify({ sample_type, value, unit }) + '\n', (err) => { // to ensure order
    if (err) {
      console.log('Error writing file', err);
    } else {
      console.log('Successfully wrote file');
      res.sendStatus(200);
      console.log(wss.clients);
      wss.clients.forEach(function each(client) {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({ sample_type, value, unit }));
        }
      });
    }
  });
  
});

app.listen(4002, () => console.log('app is listening on port 4002 (HTTP).'));
