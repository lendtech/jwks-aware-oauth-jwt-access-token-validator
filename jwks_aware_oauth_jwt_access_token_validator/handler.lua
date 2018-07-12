local BasePlugin = require "kong.plugins.base_plugin"
local JwksAwareJwtAccessTokenHandler = BasePlugin:extend()
-- Using modified version of Rest OIDC library
-- local openidc = require("resty.openidc")
local openidc = require("kong.plugins.jwks_aware_oauth_jwt_access_token_validator.openidc")
local utils = require("kong.plugins.oidc.utils")
local filter = require("kong.plugins.oidc.filter")
local singletons = require "kong.singletons"

local cjson = require("cjson")
local get_method = ngx.req.get_method
local req_set_header = ngx.req.set_header

JwksAwareJwtAccessTokenHandler.PRIORITY = 1000


local function extract(config) 
  local jwt
  local err
  local header = ngx.req.get_headers()[config.token_header_name]
  
  if header == nil then
    err = "No token found using header: " .. config.token_header_name
    ngx.log(ngx.ERR, err)
    return nil, err
  end
  
  if header:find(" ") then
    local divider = header:find(' ')
    if string.lower(header:sub(0, divider-1)) == string.lower("Bearer") then
      jwt = header:sub(divider+1)
      if jwt == nil then
        err = "No Bearer token value found from header: " .. config.token_header_name
        ngx.log(ngx.ERR, err)
        return nil, err
      end
    end
  end
  
  if jwt == nil then
    jwt =  header
  end
  
  ngx.log(ngx.DEBUG, "JWT token located using header: " .. config.token_header_name .. ", token length: " .. string.len(jwt))
  return jwt, err
end


local function load_consumer(consumer_id)
  local result, err = singletons.db.consumers:select { id = consumer_id }
  if not result then
    err = "Consumer: " .. consumer_id .. " not found!"
    ngx.log(ngx.ERR, err)
    return nil, err
  end
  return result
end

function JwksAwareJwtAccessTokenHandler:new()
  JwksAwareJwtAccessTokenHandler.super.new(self, "JwksAwareJwtAccessTokenHandler")
end

function JwksAwareJwtAccessTokenHandler:access(config)
  JwksAwareJwtAccessTokenHandler.super.access(self)

  if not config.run_on_preflight and get_method() == "OPTIONS" then
    return
  end

  if ngx.ctx.authenticated_credential and config.anonymous ~= "" then
    return
  end
  
  if filter.shouldProcessRequest(config) then
    handle(config)
  else
    ngx.log(ngx.DEBUG, "JwksAwareJwtAccessTokenHandler ignoring request, path: " .. ngx.var.request_uri)
  end

  ngx.log(ngx.DEBUG, "JwksAwareJwtAccessTokenHandler done")
end

function handle(config)
  local token, error = extract(config)
  if token == null or error then
    utils.exit(ngx.HTTP_UNAUTHORIZED, error, ngx.HTTP_UNAUTHORIZED)
  else
    local json, err = openidc.jwt_verify(token, config)
    if token == null or err then
      ngx.log(ngx.ERR, "JwksAwareJwtAccessTokenHandler - failed to validate access token")
      utils.exit(ngx.HTTP_UNAUTHORIZED, err, ngx.HTTP_UNAUTHORIZED)
    else
      ngx.log(ngx.DEBUG, "JwksAwareJwtAccessTokenHandler - Successfully validated access token")
      if config.ensure_consumer_present then
        ngx.log(ngx.DEBUG, "Consumer presence is required")
        local cid = json[config.consumer_claim_name]
        if cid == nil or cid == '' then
          ngx.log(ngx.ERR, "Consumer ID could not be read using claim: " .. config.consumer_claim_name)
          utils.exit(ngx.HTTP_UNAUTHORIZED, error, ngx.HTTP_UNAUTHORIZED)
        else
          ngx.log(ngx.DEBUG, "Consumer ID: " .. cid .. " read using claim: " .. config.consumer_claim_name)
          local consumer, e = load_consumer(cid)
          if consumer == null or e then
            ngx.log(ngx.ERR, "Consumer ID could not be fetched for cid: " .. cid)
            utils.exit(ngx.HTTP_UNAUTHORIZED, error, ngx.HTTP_UNAUTHORIZED)
          else
            ngx.ctx.authenticated_consumer = consumer
            ngx.ctx.authenticated_credential = cid
            req_set_header(config.upstream_jwt_header_name, token) -- TODO: Not working, to be tested!
            -- TODO: Check for possible issuer, audience and other configurable claims verification
            -- TODO: Validate for access token expiration etc.
          end
        end
      end
    end
  end
end

return JwksAwareJwtAccessTokenHandler
