import os
import sys
import time
import threading

try:
    import win32event
    import win32service
    import win32serviceutil
except Exception:
    raise SystemExit("pywin32 is required to run this service. Install with: pip install pywin32")

from http import server
import socketserver

SERVICE_NAME = "WaterZummarServer"
SERVICE_DISPLAY_NAME = "WaterZummar HTTP Server"


class ServerThread(threading.Thread):
    def __init__(self, port=9000):
        super().__init__()
        self.port = port
        self.httpd = None
        self._stop_event = threading.Event()

    def run(self):
        class Handler(server.SimpleHTTPRequestHandler):
            def end_headers(self):
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', '*')
                super().end_headers()

        try:
            with socketserver.TCPServer(("", self.port), Handler) as httpd:
                self.httpd = httpd
                # Serve until stop requested
                while not self._stop_event.is_set():
                    httpd.handle_request()
        except Exception:
            # let service wrapper handle logging
            raise

    def stop(self):
        self._stop_event.set()
        # create a dummy connection to unblock handle_request
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(('127.0.0.1', self.port))
            s.close()
        except Exception:
            pass


class WaterZummarService(win32serviceutil.ServiceFramework):
    _svc_name_ = SERVICE_NAME
    _svc_display_name_ = SERVICE_DISPLAY_NAME

    def __init__(self, args):
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)
        self.server_thread = None

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        if self.server_thread:
            self.server_thread.stop()
            self.server_thread.join(timeout=5)
        win32event.SetEvent(self.hWaitStop)

    def SvcDoRun(self):
        # change working directory to script directory
        script_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(script_dir)

        # read port from args or use default
        port = 9000
        try:
            if len(sys.argv) > 1:
                # when run as script, sys.argv contains install/start args; service receives different args
                pass
        except Exception:
            pass

        self.server_thread = ServerThread(port=port)
        self.server_thread.daemon = True
        self.server_thread.start()

        # Wait until stop event is signaled
        win32event.WaitForSingleObject(self.hWaitStop, win32event.INFINITE)


if __name__ == '__main__':
    # Allow normal commandline operations: install, remove, start, stop
    win32serviceutil.HandleCommandLine(WaterZummarService)
