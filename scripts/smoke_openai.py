import os

from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from openai import OpenAI

endpoint = os.environ["AZURE_OPENAI_ENDPOINT"].rstrip("/")

token_provider = get_bearer_token_provider(
    DefaultAzureCredential(), "https://cognitiveservices.azure.com/.default"
)

client = OpenAI(base_url=f"{endpoint}/openai/v1/", api_key=token_provider)

reply = client.chat.completions.create(
    model="chat",
    messages=[{"role": "user", "content": "Explain RAG in two sentences."}],
)
print(reply.choices[0].message.content)
print("tokens:", reply.usage.total_tokens)

vector = client.embeddings.create(model="embed", input="annual leave policy")
print("embedding length:", len(vector.data[0].embedding))
print("first 5 numbers:", vector.data[0].embedding[:5])
