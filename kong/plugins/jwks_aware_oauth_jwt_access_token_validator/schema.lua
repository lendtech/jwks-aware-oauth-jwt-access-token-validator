--[[
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

***************************************************************************
Copyright (c) 2018 @gt_tech
All rights reserved.

For further information please contact: https://bitbucket.org/gt_tech/

DISCLAIMER OF WARRANTIES:

THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT
ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY; INCLUDING,
WITHOUT LIMITATION, WARRANTIES OF QUALITY, PERFORMANCE, NONINFRINGEMENT,
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  NOR ARE THERE ANY
WARRANTIES CREATED BY A COURSE OR DEALING, COURSE OF PERFORMANCE OR TRADE
USAGE.  FURTHERMORE, THERE ARE NO WARRANTIES THAT THE SOFTWARE WILL MEET
YOUR NEEDS OR BE FREE FROM ERRORS, OR THAT THE OPERATION OF THE SOFTWARE
WILL BE UNINTERRUPTED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

@Author: https://bitbucket.org/gt_tech/

--]]
local typedefs = require "kong.db.schema.typedefs"
local utils = require "kong.tools.utils"
local Errors = require "kong.db.errors"
local az = require("kong.plugins.jwks_aware_oauth_jwt_access_token_validator.authorization")

return {
  name = "jwks_aware_oauth_jwt_access_token_validator",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { token_header_name = {type = "string", required = true, default = "Authorization"}, },
          { discovery = {type = "string", required = true}, },
          { auto_discover_issuer = {type = "boolean", required = false, default = false}, },
          { expected_issuers = {type = "array", required = false, elements = { type = "string" } }, },
          { accepted_audiences = {type = "array", required = false, elements = { type = "string" } }, },
          { ssl_verify = {type = "string", default = "no"}, },
          { jwk_expires_in = {type = "number", required = false, default = 7200 }, },
          { ensure_consumer_present = {type = "boolean", required = false, default = false}, },
          { consumer_claim_name = {type = "string", default = "appid"}, },
          { run_on_preflight = {type = "boolean", required = false, default = false}, },
          { upstream_jwt_header_name = {type = "string", required = true, default = "validated_jwt"}, },
          { accept_none_alg = {type = "boolean", required = false, default = false}, },
          { iat_slack = {type = "number", required = false, default = 120 }, },
          { timeout = {type = "number", required = false, default = 3000 }, },
          { anonymous = {type = "string" }, },
          { filters = { type = "string" }, },
          { enable_authorization_rules = { type = "boolean", required = true, default = false }, },
          { authorization_claim_name = { type = "string", required = true, default = "roles" }, },
          { implicit_authorize = { type = "boolean", required = true, default = false }, },
          { whitelist = { type = "array", required = false, elements = { type = "string" } }, },
          { blacklist = { type = "array", required = false, elements = { type = "string" } }, },
        },
      },
    },
  },
}
