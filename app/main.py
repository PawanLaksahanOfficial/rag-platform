from fastapi import FastAPI
from pydantic import BaseModel

from app.chunking import chunk_text

app = FastAPI(title="rag-platform")


class ChunkRequest(BaseModel):
    text: str
    size: int = 200
    overlap: int = 50


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/chunk")
def chunk(request: ChunkRequest) -> dict:
    chunks = chunk_text(request.text, request.size, request.overlap)
    return {"count": len(chunks), "chunks": [c.text for c in chunks]}
