from typing import Self

from fastapi import FastAPI
from pydantic import BaseModel, Field, model_validator

from app.chunking import chunk_text

MAX_TEXT_CHARS = 100_000
MAX_CHUNK_WORDS = 1_000

app = FastAPI(title="rag-platform")


class ChunkRequest(BaseModel):
    text: str = Field(min_length=1, max_length=MAX_TEXT_CHARS)
    size: int = Field(default=200, ge=1, le=MAX_CHUNK_WORDS)
    overlap: int = Field(default=50, ge=0)

    @model_validator(mode="after")
    def overlap_must_be_smaller_than_size(self) -> Self:
        if self.overlap >= self.size:
            raise ValueError("overlap must be smaller than size")
        return self


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/chunk")
def chunk(request: ChunkRequest) -> dict:
    chunks = chunk_text(request.text, request.size, request.overlap)
    return {"count": len(chunks), "chunks": [c.text for c in chunks]}
