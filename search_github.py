import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

req = urllib.request.Request(
    'https://api.github.com/repos/aframevr/assets/git/trees/master?recursive=1',
    headers={'User-Agent': 'Mozilla/5.0'}
)
try:
    with urllib.request.urlopen(req, context=ctx) as response:
        data = json.loads(response.read().decode())
        for item in data.get('tree', []):
            if item['path'].endswith('.glb') or item['path'].endswith('.gltf'):
                print(item['path'])
except Exception as e:
    print(f"Error: {e}")
