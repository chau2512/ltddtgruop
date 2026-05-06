import urllib.request
try:
    req = urllib.request.Request("https://www.myinstants.com/media/sounds/yay.mp3", headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response, open("d:/matchquizapp/assets/audio/applause.mp3", 'wb') as out_file:
        out_file.write(response.read())
except Exception as e:
    pass
