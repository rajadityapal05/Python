import pandas as pd
from pathlib import Path

RAW = Path("data/raw/netflix_titles.csv")
CLEANED = Path("data/cleaned/netflix_titles_cleaned.csv")

if not RAW.exists():
    raise FileNotFoundError("Run download_data.py first.")

df = pd.read_csv(RAW)

df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_", regex=False)
)

text_columns = [
    "show_id", "type", "title", "director", "cast",
    "country", "rating", "duration", "listed_in", "description"
]

for col in text_columns:
    if col in df.columns:
        df[col] = df[col].fillna("Unknown").astype(str).str.strip()

if "date_added" in df.columns:
    df["date_added"] = pd.to_datetime(df["date_added"], errors="coerce")

if "release_year" in df.columns:
    df["release_year"] = pd.to_numeric(df["release_year"], errors="coerce")

df = df.drop_duplicates(subset=["show_id"])

CLEANED.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(CLEANED, index=False)

print("DATA PREPARATION COMPLETE")
print(f"Rows: {len(df):,}")
print(f"Columns: {len(df.columns)}")
print(f"Saved: {CLEANED}")
