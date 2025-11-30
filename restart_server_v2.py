import os
import sys
import subprocess
import time

def get_pid_on_port(port):
    try:
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

print("Starting new server...")
# Use Popen to start independent process
with open('server_out.log', 'w') as out, open('server_err.log', 'w') as err:
    subprocess.Popen([sys.executable, "server.py"], cwd=os.getcwd(), stdout=out, stderr=err)

print("Server started. Checking status...")
time.sleep(2)
pid = get_pid_on_port(9000)
if pid:
    print(f"Server is running on PID {pid}")
else:
    print("Server failed to start. Check logs.")
