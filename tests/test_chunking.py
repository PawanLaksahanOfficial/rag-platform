import pytest
from app.chunking import chunk_text

def test_short_text_gives_one_chunk():
    chunks = chunk_text("a b c", size=10, overlap=2)
    assert len(chunks) == 1
    assert chunks[0].text == "a b c"

def test_chunks_overlap():
    text = " ".join(str(n) for n in range(30))
    chunks = chunk_text(text, size=10, overlap=5)
    first_tail = chunks[0].text.split()[-5:]
    second_head = chunks[1].text.split()[:5]
    assert first_tail == second_head

def test_overlap_must_be_smaller_than_size():
    with pytest.raises(ValueError):
        chunk_text("a b c", size=5, overlap=5)