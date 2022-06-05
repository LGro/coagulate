from pydantic import BaseModel


class Profile(BaseModel):
    shared_id: str
    encrypted_profile: str


class OPRFRequest(BaseModel):
    oprf_request: str


class QueryRequest(BaseModel):
    query_request: str


class OPRFResponse(BaseModel):
    oprf_response: str


class QueryResponse(BaseModel):
    query_response: str
