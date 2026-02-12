import os
import re

directory = 'assets/avatars'
files = os.listdir(directory)

# Filter for files that are just numbers .png (e.g. "21.png", "22.png", "23.png")
# and exclude those that already start with "avatar_"
numeric_files = [f for f in files if re.match(r'^\d+\.png$', f)]

# Sort numerically to maintain some order
numeric_files.sort(key=lambda x: int(os.path.splitext(x)[0]))

# Determine start index for renaming
# Find the highest existing avatar_N.png
existing_avatars = [f for f in files if f.startswith('avatar_') and f.endswith('.png')]
max_index = 0
for f in existing_avatars:
    try:
        idx = int(f.replace('avatar_', '').replace('.png', ''))
        if idx > max_index:
            max_index = idx
    except ValueError:
        pass

start_index = max_index + 1

print(f"Found {len(numeric_files)} new files. Renaming starting from avatar_{start_index}.png")

for i, filename in enumerate(numeric_files):
    old_path = os.path.join(directory, filename)
    new_name = f"avatar_{start_index + i}.png"
    new_path = os.path.join(directory, new_name)
    os.rename(old_path, new_path)
    print(f"Renamed {filename} -> {new_name}")
