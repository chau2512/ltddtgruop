import os

folder = "d:/matchquizapp/assets/audio"
for filename in os.listdir(folder):
    if filename.endswith(".mp3"):
        path = os.path.join(folder, filename)
        size = os.path.getsize(path)
        with open(path, 'rb') as f:
            head = f.read(20)
        print(f"{filename}: size={size} bytes, head={head}")
