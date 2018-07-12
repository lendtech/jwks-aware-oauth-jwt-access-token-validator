# jwks_aware_oauth_jwt_access_token_validator

Quick prototype repository to create a custom plugin for validating JWT bearer OAuth access token that utilize OAuth discovery endpoints. Plugin largely utilizes openidc rest library.

7/11/18: To be formatted later with proper instructions.


For Client application: https://oidc-simple-client.azurewebsites.net/


For standing up local Kong environment, docker and docker-compose setup is required. Clone the repository and fire following commands:
```
docker-compose build --force-rm  && docker-compose up -d
```