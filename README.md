## What is this Fork?
This fork updates the [jwks_aware_oauth_jwt_access_token_validator](https://bitbucket.org/gt_tech/jwks_aware_oauth_jwt_access_token_validator) plugin to make it compatible with version 3.x+ of Kong.

## What is "_jwks_aware_oauth_jwt_access_token_validator_" Kong plugin?

This plugin is for authenticating API requests by means of bearer JWT tokens whose signatures can be verified by using a [JWK](https://tools.ietf.org/html/rfc7517) fetched from a remote JWKS endpoint.

The default JWT plugin inbuilt with Kong Gateway doesn't have the capability to work with JWKS which this plugin solves for.

This plugin can also be used for JWT obtained as a result of [OIDC](http://openid.net/connect/) in specific cases where IDP providers uses JWT bearer token format for OIDC/OAuth access tokens. (For e.g. [Azure OIDC](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-v2-protocols-oidc)).

This plugin can also be used in conjunction with other Kong plugins like Rate limiting etc. as it provides a configurable ability to load and set Kong consumers based on any claim key value in incoming JWT token. This setting is optional and is disabled by default.

## Plugin schema/configuration

### Parameters

| Parameter | Default  | Required | description |
| --- | --- | --- | --- |
| `name` || true | plugin name, has to be `jwks_aware_oauth_jwt_access_token_validator` |
| `config.token_header_name` | Authorization | true | Name of request header which contains the incoming JWT token |
| `config.discovery` | | true | OIDC Discovery Endpoint (`/.well-known/openid-configuration`) to obtain JWKS endpoint |
| `config.auto_discover_issuer` | false | false | Setting to auto-discover JWT issuer value from discovery endpoint |
| `config.ssl_verify` | false | false | Enable SSL verification to OIDC Provider. It is recommended to enable this setting in `PRODUCTION` environments for security, Kong gateway must have root and intermediate certificates available. |
| `config.expected_issuers` | {} | false | Array of issuer values which are expected in in-coming JWT token. If this is left empty, issuer-check is not performed |
| `config.accepted_audiences` | {} | false | Array of issuer values which are expected in in-coming JWT token. If this is left empty, issuer-check is not performed |
| `config.jwk_expires_in` | 7200 | false | Duration for cache of JWKS in seconds |
| `config.ensure_consumer_present` | false | false | Setting to ensure if consumer is present in Kong database. This setting enables setting of consumer in Kong context which can be used with other plugins like [Rate-limiting plugin](https://docs.konghq.com/plugins/rate-limiting/) as example. |
| `config.consumer_claim_name` | appid | false | Name of the claim in JWT to obtain consumer value |
| `config.run_on_preflight` | false | false | Setting to control if plugin would execute on `OPTIONS` request |
| `config.upstream_jwt_header_name` | validated_jwt | true | Name of the request header to be used for sending validated JWT to upstream ORIGIN server. ORIGIN can simply extract desired claims from JWT without worrying about verification as verification is done by this plugin |
| `config.accept_none_alg` | false | false | Setting to control unsigned JWT will ve accepted for authentication |
| `config.iat_slack` | 120 | false | Duration in seconds for clock-skew between JWT issuer and Kong plugin |
| `config.timeout` | 3000 | false | Duration in milli-seconds for timing out HTTP connections to `OIDC discovery` and `JWKS endpoint` |
| `config.anonymous` |  | false | Anonymous user |
| `config.filters` | | false | Comma-separated URI path patterns for request that should be ignored from plugin, for e.g. health check requests |
| `config.enable_authorization_rules` | false | true | Enables supports for whitelist/blacklist based HTTP verb-specific authorization rules. By default authorization rules enforcement is disabled. |
| `config.authorization_claim_name` | roles | true | Name of the JWT claim which will provide user claims. Target claim can carry a single value or else a multiple values (as an JSON Array) |
| `config.whitelist` | {} | true | Verb-specific whitelist rules. For example: __GET=role1__ or when specifying multiple roles (colon-separated role names), __GET=role1;role2__.  For defining multiple verb-specific roles, this can be defined as  (multiple verb specific rules can be seperated by comma)- __config.whitelist=GET=role1;role2,POST=role3;role2,DELETE=role_admin__ |
| `config.blacklist` | {} | true | Verb-specific blacklist rules. For example: __GET=role1__ or when specifying multiple roles (colon-separated role names), __GET=role10;role12__.  For defining multiple verb-specific roles, this can be defined as  (multiple verb specific rules can be seperated by comma)- __config.blacklist=GET=role20;role22,POST=role23;role22,DELETE=role_super_admin__ |
| `config.implicit_authorize` | false | true | Used to enable implicit authorization of API request when no user claims are available in provided JWT or else no configuration is available with plugin for specific HTTP method. By default implicit authorization is disabled |

## How to use
Refer to `EXAMPLE` section for more details.

## Compatibility
Kong 1.0 
(A minor change is needed in schema as explained in [pull request](https://bitbucket.org/gt_tech/jwks_aware_oauth_jwt_access_token_validator/pull-requests/2/kong-10-compatibility/diff) to make it work with older versions).


## Example setup
A docker compose and Dockerfile is provided at the root of repository which provides easy test setup. `Dockerfile` lists the operating system package as well as plugin's transitive dependencies installation command along with the logic for copying this plugin at required location. These files can be used as reference to setup plugin in target environment.

### Build and start Kong
```
docker-compose build --force-rm && docker-compose up -d
```
### Stop Kong
```
docker-compose down
```

### Stop Kong as well as remove Docker volume to be able to start from scratch
```
docker-compose down -v
```

### Create a Service
For sample setup, the example application utilize `mockbin` as upstrem API provider
```
curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=example-service' \
  --data 'url=http://mockbin.org'
```

### Add a Route to the service
```
curl -i -X POST \
  --url http://localhost:8001/services/example-service/routes \
  --data 'hosts[]=example.com'
```

### Test Service
```
curl -i -X GET \
  --url http://localhost:8000/request \
  --header 'Host: example.com' \
  --header 'Accept: application/json'
```

### Add this Authentication plugin to the service
```
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=jwks_aware_oauth_jwt_access_token_validator' \
  --data 'config.discovery=https://login.microsoftonline.com/b3bae44c-fc92-4bb3-a366-d559e07ca19a/.well-known/openid-configuration'
```

Above sample command uses author's test setup for `discovery` endpoint. Users must use their environment specific discovery endpoint.

After the plugin is added, if Service is tested again, it will result in `unauthorized` access error.

### Test service with proper authentication
```
curl -i -X GET \
 --url http://localhost:8000/request \
 --header 'Host: example.com' \
 --header 'Accept: application/json' \
 --header 'Authorization: Bearer <jwt_token>'
```

Check the response, `Authorization` header isn't sent to upstream ORIGIN service and instead a `validated_jwt` header is sent to it.

### Add Issuer validation to plugin
```
curl -X PATCH http://localhost:8001/plugins/bc363893-f043-41aa-a657-30632a8d07e2 \
   --data "config.expected_issuers=https://sts.windows.net/b3bae44c-fc92-4bb3-a366-d559e07ca19a/"
```

Above example uses a issuer value from author's test setup. Users must use their environment specific value.

### Enable Authorization rules support
Following plugin configuration options can be used to enable authorization rules support. Individual configuration details are explained above in __*"Plugin schema/configuration"*__ section. 

* enable_authorization_rules
* authorization_claim_name
* whitelist
* blacklist
* implicit_authorize

**Note** that blacklist rules result takes precedence over whitelist rules if a particular API request satisfies both the list's configuration.

## Credit
This plugin gives credit to [Kong OIDC](https://github.com/nokia/kong-oidc) plugin as well as [Resty OIDC](https://github.com/zmartzone/lua-resty-openidc) library as it leverages functionality provided by those components.

## Central package management
[Luarocks](https://luarocks.org/modules/gttech/jwks_aware_oauth_jwt_access_token_validator)

## Bugs and feature requests
Have a bug or a feature request? Please use [issue tracker](https://bitbucket.org/gt_tech/jwks_aware_oauth_jwt_access_token_validator/issues?status=new&status=open) to raise a request.

## Contributing
Contributions are highly appreciated, it is encouraged to submit a [PULL request](https://bitbucket.org/gt_tech/jwks_aware_oauth_jwt_access_token_validator/pull-requests/). 
Contributors must ensure that existing test cases pass (or are modified to adjust to their changes) and appropriate documentation changes are accompanied with pull request.

## LICENSE
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


