const http = require("http");

http
  .createServer((req, res) => {
    if (req.url === "/hello") {
      res.writeHead(200);
      res.end("hello");
    } else {
      res.writeHead(404);
      res.end();
    }
  })
  .listen(8082, "0.0.0.0");
