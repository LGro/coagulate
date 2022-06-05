import base64

from fastapi.testclient import TestClient
from apsi import LabeledClient

from coagulate_server.main import app
from coagulate_server.config import APSI_PARAMS

client = TestClient(app)


def test_profiles():
    apsi_client = LabeledClient(APSI_PARAMS)

    response = client.post(
        "/profiles",
        json={
            "shared_id": "my-profile-id",
            "encrypted_profile": "base64-encoded-encrypted-profile",
        },
    )
    assert response.ok, response.content.decode("utf-8")

    oprf_request = apsi_client.oprf_request(["my-profile-id"])
    response = client.get(
        "/profiles/oprf",
        json={"oprf_request": base64.b64encode(oprf_request).decode("ascii")},
    )
    assert response.ok, response.content.decode("utf-8")
    oprf_response = base64.b64decode(response.json()["oprf_response"])

    query = apsi_client.build_query(oprf_response)
    response = client.get(
        "/profiles/query",
        json={"query_request": base64.b64encode(query).decode("ascii")},
    )
    assert response.ok, response.content.decode("utf-8")
    query_response = base64.b64decode(response.json()["query_response"])

    result = apsi_client.extract_result(query_response)
    assert result == {"my-profile-id": "base64-encoded-encrypted-profile"}
