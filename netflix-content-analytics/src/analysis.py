import pandas as pd
from pathlib import Path

DATA = Path("data/cleaned/netflix_titles_cleaned.csv")
OUTPUT = Path("data/cleaned")

df = pd.read_csv(DATA)

print("=" * 60)
print("NETFLIX CONTENT ANALYTICS")
print("=" * 60)

print(f"\nTotal titles: {len(df):,}")

print("\nContent Type:")
print(df["type"].value_counts())

print("\nTop Countries:")
print(df["country"].value_counts().head(10))

print("\nTop Ratings:")
print(df["rating"].value_counts().head(10))

print("\nRecent Release Years:")
print(
    df["release_year"]
    .value_counts()
    .sort_index()
    .tail(10)
)

df["type"].value_counts().rename_axis("type").reset_index(
    name="content_count"
).to_csv(
    OUTPUT / "content_type_summary.csv",
    index=False
)

df["rating"].value_counts().rename_axis("rating").reset_index(
    name="content_count"
).to_csv(
    OUTPUT / "rating_summary.csv",
    index=False
)

print("\nANALYSIS COMPLETE")
print("Summary files exported to data/cleaned/")
