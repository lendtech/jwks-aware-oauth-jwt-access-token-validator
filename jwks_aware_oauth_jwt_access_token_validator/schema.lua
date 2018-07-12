local utils = require "kong.tools.utils"
local Errors = require "kong.dao.errors"

local function check_user(anonymous)
  if anonymous == "" or utils.is_valid_uuid(anonymous) then
    return true
  end

  return false, "the anonymous user must be empty or a valid uuid"
end

local function check_positive(v)
  if v < 0 then
    return false, "should be 0 or greater"
  end

  return true
end

return {
  no_consumer = true,
  fields = {
    token_header_name = {type = "string", required = false, default = "Authorization"},
    discovery = {type = "url", required = true},
    ssl_verify = {type = "string", default = "no"},
    jwk_expires_in = {type = "number", required = false, default = 7200, func = check_positive},
    ensure_consumer_present = {type = "boolean", required = false, default = false},
    consumer_claim_name = {type = "string", default = "appid"},
    run_on_preflight = {type = "boolean", required = false, default = false},
    upstream_jwt_header_name = {type = "string", required = false, default = "jwt"},
    accept_none_alg = {type = "boolean", required = false, default = false},
    iat_slack = {type = "number", required = false, default = 120, func = check_positive},
    anonymous = {type = "string", default = "", func = check_user},
    filters = { type = "string" }
  },
  self_check = function(schema, plugin_t, dao, is_update)
    if plugin_t.ensure_consumer_present       
    then
      if plugin_t.consumer_claim_name == nil or plugin_t.consumer_claim_name == '' then
        return false, Errors.schema "consumer_claim_name must be defined when ensure_consumer_present is enabled"
      end
    end
    
    if plugin_t.token_header_name == nil or plugin_t.token_header_name == '' then
        return false, Errors.schema "token_header_name must not be blank!"
      end

    return true
  end
}


