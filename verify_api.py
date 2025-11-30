import urllib.request
import urllib.error

try:
    with urllib.request.urlopen('http://127.0.0.1:9000/api/data') as response:
        print(f"Status: {response.status}")
        print(f"Content: {response.read().decode('utf-8')}")
except urllib.error.URLError as e:
    print(f"Error: {e}")
