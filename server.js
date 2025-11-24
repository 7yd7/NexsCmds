const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const hostname = '0.0.0.0';
const port = 3000;

function getLocalExternalIP() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return 'YOUR_PC_IP';
}

const server = http.createServer((req, res) => {
    if (req.method === 'GET') {
        let filePath;
        if (req.url === '/' || req.url === '/script') {
            filePath = path.join(__dirname, 'client.luau');
        } else if (req.url.endsWith('.luau') || req.url.endsWith('.json')) {
            filePath = path.join(__dirname, req.url);
        }

        if (filePath) {
            fs.readFile(filePath, 'utf8', (err, data) => {
                if (err) {
                    console.error('Error reading file:', err);
                    if (err.code === 'ENOENT') {
                        res.statusCode = 404;
                        res.end('Error: File not found!');
                    } else {
                        res.statusCode = 500;
                        res.end('Internal Server Error');
                    }
                    return;
                }
                res.statusCode = 200;
                res.setHeader('Content-Type', 'text/plain');
                res.end(data);
            });
            return;
        }
    }

    if (req.method === 'POST' && req.url === '/log') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            console.log('Received from Lua:', body);
            res.statusCode = 200;
            res.setHeader('Content-Type', 'text/plain');
            res.end('Log received\n');
        });
    } else {
        res.statusCode = 404;
        res.end('Not Found\n');
    }
});

server.listen(port, hostname, () => {
    const localIP = getLocalExternalIP();
    console.log(`Server running!`);
    console.log(`- Local: http://localhost:${port}/`);
    console.log(`- Network: http://${localIP}:${port}/`);
});
