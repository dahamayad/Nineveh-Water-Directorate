#!/usr/bin/env python3
"""
Simple HTTP Server for Water Distribution Management System
Handles multiple requests and refreshes properly
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import unquote

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    extensions_map = http.server.SimpleHTTPRequestHandler.extensions_map.copy()
    extensions_map['.html'] = 'text/html; charset=utf-8'

    def end_headers(self):
        # Add CORS headers to allow all origins
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_GET(self):
        print(f"DEBUG: GET request for {self.path}", file=sys.stderr)
        if self.path == '/api/data' or self.path.startswith('/api/data?'):
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            data_file = 'data.json'
            if os.path.exists(data_file):
                with open(data_file, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.wfile.write(b'{"employees": [], "areas": [], "schedules": []}')
            return
        
        return super().do_GET()

    def do_POST(self):
        if self.path == '/api/data':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            with open('data.json', 'wb') as f:
                f.write(post_data)
                
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "success"}')
            return
            
        return super().do_POST()

    def log_message(self, format, *args):
        # Custom logging to show requests
        sys.stderr.write("%s - %s\n" %
                        (self.address_string(),
                         format%args))

def run_server(port=9000):
    """Run the HTTP server on specified port"""
    try:
        with socketserver.TCPServer(("", port), CustomHTTPRequestHandler) as httpd:
            print(f"Server started: http://127.0.0.1:{port}")
            print("Current directory:", os.getcwd())
            print("You can now refresh the page without stopping the server")
            print("Press Ctrl+C to stop the server")
            print("-" * 50)
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped")
        sys.exit(0)
    except OSError as e:
        if hasattr(e, 'errno') and e.errno == 48:  # Address already in use
            print(f"Port {port} is already in use. Try a different port or close the other server first.")
        else:
            print(f"Server error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Change to the directory containing this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    port = 9000
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("❌ المنفذ يجب أن يكون رقماً")
            sys.exit(1)

    run_server(port)