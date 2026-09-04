from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/hello":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Hello World")
        else:
            self.send_response(404)
            self.end_headers()
        print("added on main")


HTTPServer(("0.0.0.0", 8081), Handler).serve_forever()
