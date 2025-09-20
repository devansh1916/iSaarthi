from fastapi import FastAPI, Query
import pandas as pd
from sentence_transformers import SentenceTransformer, util

app = FastAPI()

# 1. Load embedding model (small + free, ~100MB)
model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# 2. Load civic issues from Google Sheets (CSV export link)
CSV_URL = "https://docs.google.com/spreadsheets/d/1W97h1PCryakGrIkIX-cDyij9_RUywGF1g31fwX9oD9Y/export?format=csv"
issues_df = pd.read_csv(CSV_URL)

# Pre-compute embeddings for all issues
issue_texts = issues_df.apply(
    lambda row: f"{row.get('Issue','')} at {row.get('Location','')}", axis=1
).tolist()
issue_embeddings = model.encode(issue_texts, convert_to_tensor=True)


@app.get("/chatbot")
def chatbot(query: str = Query(...)):
    # 3. Embed the user query
    query_embedding = model.encode(query, convert_to_tensor=True)

    # 4. Find top 3 most similar issues
    similarities = util.cos_sim(query_embedding, issue_embeddings)[0]
    top_indices = similarities.argsort(descending=True)[:3]

    # 5. Build reply with top matches
    replies = []
    for idx in top_indices:
        row = issues_df.iloc[int(idx)]
        issue = row.get("Issue", "Unknown Issue")
        location = row.get("Location", "Unknown Location")
        status = row.get("Status", "Not available")
        last_updated = row.get("LastUpdated", "Not provided")
        remarks = row.get("Remarks", "No remarks yet")

        replies.append(
            f"🔹 {issue} at {location}\n"
            f"   📌 Status: {status}\n"
            f"   🗓 Last updated: {last_updated}\n"
            f"   💬 Remarks: {remarks}"
        )

    final_reply = "Here are the most relevant issues I found:\n\n" + "\n\n".join(replies)
    return {"reply": final_reply}
