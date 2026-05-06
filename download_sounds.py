import urllib.request
import os

sounds = {
    "correct1.mp3": "https://www.myinstants.com/media/sounds/anime-wow-sound-effect.mp3",
    "correct2.mp3": "https://www.myinstants.com/media/sounds/yippee-tbh.mp3",
    "correct3.mp3": "https://www.myinstants.com/media/sounds/super-mario-coin-sound.mp3",
    "wrong1.mp3": "https://www.myinstants.com/media/sounds/fnaf-1-jumpscare-sound.mp3",
    "wrong2.mp3": "https://www.myinstants.com/media/sounds/vine-boom.mp3",
    "applause.mp3": "https://www.myinstants.com/media/sounds/kids-cheering.mp3",
    "bgm.mp3": "https://www.myinstants.com/media/sounds/kahoot-lobby-music.mp3"
}

os.makedirs("d:/matchquizapp/assets/audio", exist_ok=True)

for filename, url in sounds.items():
    print(f"Downloading {filename}...")
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(f"d:/matchquizapp/assets/audio/{filename}", 'wb') as out_file:
            out_file.write(response.read())
    except Exception as e:
        print(f"Failed to download {filename}: {e}")
