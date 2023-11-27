import http.server
import socketserver
import http.client
import json

PORT = 8080
DJANGO_SERVER_HOST = "127.0.0.1"
DJANGO_SERVER_PORT = 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200, "OK")
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        # Parse JSON data
        data = json.loads(post_data)

        # Modify this part to send the POST request to your Django backend
        connection = http.client.HTTPConnection(DJANGO_SERVER_HOST, DJANGO_SERVER_PORT)
        headers = {'Content-type': 'application/json'}
        connection.request("POST", "/saveMeasurement/", json.dumps(data), headers)

        response = connection.getresponse()
        print(response.read().decode())
        connection.close()

        # Respond to the client
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        # Parse JSON data
        data = json.loads(post_data)

        # Modify this part to send the POST request to your Django backend
        connection = http.client.HTTPConnection(DJANGO_SERVER_HOST, DJANGO_SERVER_PORT)
        headers = {'Content-type': 'application/json'}
        connection.request("POST", "/saveMeasurement/", json.dumps(data), headers)

        response = connection.getresponse()
        print(response.read().decode())
        connection.close()

        # Respond to the client
        self.send_response(200)
        self.end_headers()

# Use MyHTTPRequestHandler as the handler
Handler = MyHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()