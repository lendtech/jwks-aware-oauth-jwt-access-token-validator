# This file is meant for author's internal use only.


## Build and start service
docker-compose build --force-rm && docker-compose up -d

## Wipe the slate
docker-compose down -v


## Add Service

curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=example-service' \
  --data 'url=http://mockbin.org'



## Add a Route for the Service

curl -i -X POST \
  --url http://localhost:8001/services/example-service/routes \
  --data 'hosts[]=example.com'


## Forward requests through Kong

curl -i -X GET \
  --url http://localhost:8000/request \
  --header 'Host: example.com' \
  --header 'Accept: application/json'




## Configure JWKS Aware JWT Plugin :

curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=jwks_aware_oauth_jwt_access_token_validator' \
  --data 'config.discovery=https://login.microsoftonline.com/b3bae44c-fc92-4bb3-a366-d559e07ca19a/.well-known/openid-configuration' \
  --data 'config.timeout=10000'

## OR ELSE Configure JWKS Aware JWT Plugin with Authorization support:
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=jwks_aware_oauth_jwt_access_token_validator' \
  --data 'config.discovery=https://login.microsoftonline.com/b3bae44c-fc92-4bb3-a366-d559e07ca19a/.well-known/openid-configuration' \
  --data 'config.timeout=10000' \
  --data 'config.enable_authorization_rules=true' \
  --data 'config.authorization_claim_name=roleCodeNgis' \
  --data 'config.whitelist=GET=NCR001'


## Forward request through Kong with Access token:

curl -i -X GET \
 --url http://localhost:8000/request \
 --header 'Host: example.com' \
 --header 'Accept: application/json' \
 --header 'Authorization: Bearer <jwt_token>'


## Create a consumer
curl -i -X POST \
  --url http://localhost:8001/consumers/ \
  --data "id=c5a84239-b020-4141-9479-c2c7dbd08194" \
  --data "username=c5a84239-b020-4141-9479-c2c7dbd08194"


## Enable Plugin to ensure that consumer presence is required (using default claim name 'appid')
curl -X PATCH http://localhost:8001/plugins/<plugin_id>  \
  --data "config.expected_issuers=https://sts.windows.net/b3bae44c-fc92-4bb3-a366-d559e07ca19a/" \
  --data "config.ensure_consumer_present=true"




