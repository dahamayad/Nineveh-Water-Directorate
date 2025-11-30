import os
import sys
import subprocess
import time

def get_pid_on_port(port):
    try:
        # Run netstat and capture output
        cmd = f"netstat -ano | findstr :{port}"
        output = subprocess.check_output(cmd, shell=True).decode()
        lines = output.strip().split('\n')
        for line in lines:
            if 'LISTENING' in line:
                parts = line.split()
                return int(parts[-1])
    except subprocess.CalledProcessError:
        return None
    except Exception as e:
        print(f"Error finding PID: {e}")
        return None
    return None

pid = get_pid_on_port(9000)
if pid:
    print(f"Found server on PID {pid}. Stopping it...")
    subprocess.call(f"taskkill /F /PID {pid}", shell=True)
    time.sleep(2)
else:
    print("No server found on port 9000.")

print("Starting new server...")
# Start server in a new window so it persists
subprocess.Popen(["start", "python", "server.py"], shell=True, cwd=os.getcwd())
print("Server restart initiated.")
