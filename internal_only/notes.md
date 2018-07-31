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




## Forward request through Kong with Access token:

curl -i -X GET \
 --url http://localhost:8000/request \
 --header 'Host: example.com' \
 --header 'Accept: application/json' \
 --header 'Authorization: Bearer <jwt_token>'



