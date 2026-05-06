import urllib.request

urls = {
    "wrong2.mp3": "https://www.myinstants.com/media/sounds/fnaf-1-jumpscare-sound.mp3",
    "wrong3.mp3": "https://www.myinstants.com/media/sounds/fnaf-2-jumpscare_2.mp3",
    "wrong4.mp3": "https://www.myinstants.com/media/sounds/scary-jumpscare-sound.mp3"
}

for filename, url in urls.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = response.read()
            if data.startswith(b"ID3") or data.startswith(b"\xff\xfb") or b"mp3" in data[:100] or data.startswith(b"RIFF"):
                with open(f"d:/matchquizapp/assets/audio/{filename}", 'wb') as out_file:
                    out_file.write(data)
                print(f"Downloaded {filename}")
            else:
                print(f"Not an audio file: {filename}")
    except Exception as e:
        print(f"Failed to download {filename}: {e}")
