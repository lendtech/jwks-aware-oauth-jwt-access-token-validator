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
 --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlRpb0d5d3dsaHZkRmJYWjgxM1dwUGF5OUFsVSIsImtpZCI6IlRpb0d5d3dsaHZkRmJYWjgxM1dwUGF5OUFsVSJ9.eyJhdWQiOiJodHRwczovL09wdHVtR2Vub21peG91dGxvb2sub25taWNyb3NvZnQuY29tL2ZkMDQ2MmIwLTQyM2UtNDNjZi04Y2NkLWU3NTA1ZDNlZjEwMSIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L2IzYmFlNDRjLWZjOTItNGJiMy1hMzY2LWQ1NTllMDdjYTE5YS8iLCJpYXQiOjE1MzEzNjA2MzMsIm5iZiI6MTUzMTM2MDYzMywiZXhwIjoxNTMxMzY0NTMzLCJhY3IiOiIxIiwiYWlvIjoiNDJCZ1lPRGMxUE5UWmZWVEZ2T3A1U2JMT215RHM0V0tDNTRGQ0xTdlVIdjM3dm1sNG8wQSIsImFtciI6WyJwd2QiXSwiYXBwaWQiOiJjNWE4NDIzOS1iMDIwLTQxNDEtOTQ3OS1jMmM3ZGJkMDgxOTQiLCJhcHBpZGFjciI6IjEiLCJmYW1pbHlfbmFtZSI6IlR5YWdpIiwiZ2l2ZW5fbmFtZSI6IkdhdXJhdiIsImlwYWRkciI6IjE5OC4yMDMuMTc1LjE3NSIsIm5hbWUiOiJHYXVyYXYgVHlhZ2kiLCJvaWQiOiJlN2Y0YmYyYS0xMTU5LTQyNDItOTY1NS1mODQxMTMyNzBjNmMiLCJzY3AiOiJhYWQubW9ja2JpbiIsInN1YiI6IkZwQXBUX25jbjk4cnRDRk9LbDNXalY3dXBFWkp6ODVpRXZqWVhXN1V0Z1kiLCJ0aWQiOiJiM2JhZTQ0Yy1mYzkyLTRiYjMtYTM2Ni1kNTU5ZTA3Y2ExOWEiLCJ1bmlxdWVfbmFtZSI6IkdhdXJhdlRAb3B0dW1nZW5vbWl4b3V0bG9vay5vbm1pY3Jvc29mdC5jb20iLCJ1cG4iOiJHYXVyYXZUQG9wdHVtZ2Vub21peG91dGxvb2sub25taWNyb3NvZnQuY29tIiwidXRpIjoiREc1ZWs3T0VVMGFWbG5CQThmb2xBQSIsInZlciI6IjEuMCJ9.UXoIu5jzzzxNYieciotsZORIXUyJpcLXVforIWU-AnyjJOuFDcgwJdqBLwbjngno9uaGujUT0Xfbg9HXyg78mDJJ5IB8V3uvGtiuk7Jo_C7whDAsmlhupJSU3Af3KZZciM2_w74KRk8dP8UhJ0KHjuHaykO0vd0Ky_gs1PIdfcFVV1jxMcMt0eZRnymGeOwJskOqq3-RwFpSfONPE6EtoPQgnKMhlBGSm3nVjzGnAdLHKC19bJSYdj57F2Fy3xz5GuydM6O5H4_HBJnWP_EG9oJJe4Lihc7KxwHef8oEFfyGtNaPv6gHefm520ltv7BcHzjCkKb_ElLfNby91dVlLA'


