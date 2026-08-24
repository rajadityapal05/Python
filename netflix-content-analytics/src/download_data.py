import pandas as pd
from pathlib import Path

OUTPUT = Path("data/raw/netflix_titles.csv")
OUTPUT.parent.mkdir(parents=True, exist_ok=True)

URL = "https://raw.githubusercontent.com/japnitahuja/netflix-data-analysis/main/netflix_titles.csv"

print("Downloading Netflix dataset...")

df = pd.read_csv(URL)
df.to_csv(OUTPUT, index=False)

print(f"Saved: {OUTPUT}")
print(f"Shape: {df.shape}")
