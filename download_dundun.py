import urllib.request
import os

url = "https://www.myinstants.com/media/sounds/dun_dun_1.mp3"

try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = response.read()
        
    with open("d:/matchquizapp/assets/audio/wrong1.mp3", 'wb') as f:
        f.write(data)
        
    with open("d:/matchquizapp/assets/audio/wrong2.mp3", 'wb') as f:
        f.write(data)
        
    print("Success downloaded dun_dun_1.mp3 to both wrong1 and wrong2")
except Exception as e:
    print(f"Failed: {e}")
