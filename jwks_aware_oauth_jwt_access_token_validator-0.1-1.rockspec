package = "jwks_aware_oauth_jwt_access_token_validator"
version = "3.0.0-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/lendtech/jwks-aware-oauth-jwt-access-token-validator",
  tag = "3.0.0-0"
}
description = {
  summary = "Kong JWKS aware JWT authentication Integration",
  license = "Apache 2.0",
  homepage = "https://github.com/lendtech/jwks-aware-oauth-jwt-access-token-validator",
  license = "Apache License 2.0",
  maintainer = "lendtech",
  detailed = [[
      Kong JWKS aware JWT authentication Integration.
  ]],
}
dependencies = {
  "kong-oidc ~> 3.0.0"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.jwks_aware_oauth_jwt_access_token_validator.schema"] = "kong/plugins/jwks_aware_oauth_jwt_access_token_validator/schema.lua",
    ["kong.plugins.jwks_aware_oauth_jwt_access_token_validator.handler"] = "kong/plugins/jwks_aware_oauth_jwt_access_token_validator/handler.lua",
    ["kong.plugins.jwks_aware_oauth_jwt_access_token_validator.authorization"] = "kong/plugins/jwks_aware_oauth_jwt_access_token_validator/authorization.lua",
    ["kong.plugins.jwks_aware_oauth_jwt_access_token_validator.resty-lib.openidc"] = "kong/plugins/jwks_aware_oauth_jwt_access_token_validator/resty-lib/openidc.lua"
  },
}
