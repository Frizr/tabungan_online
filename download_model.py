import urllib.request
import os

url = "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/PiggyBank/glTF-Binary/PiggyBank.glb"
output_path = "assets/wallet.glb"

try:
    print(f"Downloading {url} to {output_path}...")
    urllib.request.urlretrieve(url, output_path)
    print("Download completed.")
except Exception as e:
    print(f"Error downloading: {e}")
