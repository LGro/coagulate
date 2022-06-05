import base64

from apsi import LabeledServer
from fastapi import FastAPI

from coagulate_server import config, schemas

app = FastAPI()


APSI_SERVER = LabeledServer()
APSI_SERVER.init_db(config.APSI_PARAMS, max_label_length=config.APSI_MAX_LABEL_LENGTH)


@app.get("/")
def root():
    return {"message": "Let's Coagulate!"}


@app.post("/profiles")
def post_profile(profile: schemas.Profile):
    APSI_SERVER.add_item(item=profile.shared_id, label=profile.encrypted_profile)


@app.get("/profiles/oprf", response_model=schemas.OPRFResponse)
def get_oprf_profile(oprf_request: schemas.OPRFRequest):
    oprf_response = APSI_SERVER.handle_oprf_request(
        base64.b64decode(oprf_request.oprf_request)
    )
    return {"oprf_response": base64.b64encode(oprf_response).decode("ascii")}


@app.get("/profiles/query", response_model=schemas.QueryResponse)
def get_query_profile(query: schemas.QueryRequest):
    query_response = APSI_SERVER.handle_query(base64.b64decode(query.query_request))
    return {"query_response": base64.b64encode(query_response).decode("ascii")}
