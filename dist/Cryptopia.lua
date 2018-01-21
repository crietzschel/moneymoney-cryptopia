-- Inofficial Cryptopia Extension (www.cryptopia.co.nz) for MoneyMoney
-- Fetches balances from Cryptopia API and returns them as securities
--
-- Username: Cryptopia API Key
-- Password: Cryptopia API Secret
--
-- Copyright (c) 2018 crietzschel
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking {
  version     = 1.0,
  url         = "https://www.cryptopia.co.nz/Api",
  description = "Fetch balances from Cryptopia API and list them as securities",
  services    = { "Cryptopia Account" },
}

local apiKey
local apiSecret
local balances
local currency

local currencySymbols = {
  -- match names of cryptopia vs. cryptocompare
  -- more to add ...
  STRC = "srcstar"
}

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Cryptopia Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  apiKey = username
  apiSecret = password
  currency = "EUR"
end

function ListAccounts (knownAccounts)
  local account = {
    name = market,
    accountNumber = "Cryptopia Account",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}

  balances = queryPrivate("GetBalance")
  local eurPrices = queryCryptoCompare("pricemulti", "?fsyms=" .. assetPrices() .. "&tsyms=EUR")

  for key, value in pairs(balances) do

    if tonumber(value["Total"]) > 0 then
      s[#s+1] = {
        name = value["Symbol"],
        market = market,
        currency = nil,
        quantity = value["Total"],
        price = eurPrices[symbolForAsset(value["Symbol"])]["EUR"],
      }
    end
  end

  return {securities = s}
end

function symbolForAsset(asset)
  return currencySymbols[asset] or asset
end

function assetPrices()
  local assets = ""
  for key, value in pairs(balances) do
    if tonumber(value["Total"]) > 0 then
      assets = assets .. symbolForAsset(value["Symbol"]) .. ','
    end
  end
  return assets
end

function EndSession ()
end


function hex2str(hex)
 return (hex:gsub("..", function (byte)
   return string.char(tonumber(byte, 16))
 end))
end

function queryPrivate(method)
  local path =  "/" .. method
  local nonce = string.format("%d", math.floor(MM.time()))
  local postData = '{"":""}' -- get all balances
  local postDataMd5 = hex2str(MM.md5(postData))
  local reqCont = MM.base64(postDataMd5, true)

  local urlenc = string.lower(MM.urlencode(url .. path))
  local signature = apiKey .. "POST" .. urlenc .. nonce .. reqCont
  local hmacsignature =  MM.base64(MM.hmac256(MM.base64decode(apiSecret),signature))

  local headers = {}
  headers["Authorization"] = "amx " .. apiKey .. ":" .. hmacsignature .. ":" .. nonce
  connection = Connection()
  content = connection:request("POST", url .. path, postData, "application/json; charset=utf-8", headers)

  json = JSON(content)

  return json:dictionary()["Data"]
end

function queryCryptoCompare(method, query)
  local path = string.format("/%s/%s", "data", method)

  connection = Connection()
  content = connection:request("GET", "https://min-api.cryptocompare.com" .. path .. query)
  json = JSON(content)

  return json:dictionary()
end

-- SIGNATURE: MC0CFQCW6auOlrhvjGHo9l8iRl2HB24L5QIUPgI9MtoTXBgBhRNmunsko5swufg=
