import urllib.request

urls = [
    "https://www.myinstants.com/media/sounds/horror-violin.mp3",
    "https://www.myinstants.com/media/sounds/suspense-sound.mp3",
    "https://www.myinstants.com/media/sounds/psycho-screech.mp3",
    "https://www.myinstants.com/media/sounds/dun-dun-dun.mp3"
]

for url in urls:
    try:
        print(f"Trying {url}")
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open("d:/matchquizapp/assets/audio/wrong1.mp3", 'wb') as out_file:
            out_file.write(response.read())
        print(f"Success with {url}!")
        break
    except Exception as e:
        print(f"Failed: {e}")
