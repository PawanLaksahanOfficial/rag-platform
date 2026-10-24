from dataclasses import dataclass

@dataclass
class Chunk:
    index: int
    text:str

def chunk_text(text: str, size: int = 200, overlap: int = 50) -> list[Chunk]:
    if overlap >= size:
        raise ValueError("overlap must be smaller than size")
    words = text.split()
    step = size - overlap
    chunks: list[Chunk] = []

    for i, start in enumerate(range(0, len(words), step)):
        piece = words[start:start + size]
        chunks.append(Chunk(index=i, text=" ".join(piece)))
        if start + size >= len(words):
            break

    return chunks

if __name__ == "__main__":
    sample = " ".join(f"word{n}" for n in range(500))
    for c in chunk_text(sample):
        print(c.index, c.text[:40], "...")