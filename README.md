# moneymoney-cryptopia

Fetches balances from cryptopia.co.nz API and returns them as securities. 
Prices in EUR from cryptocompare.com.

Requirements:
* MoneyMoney v2.3.5

## Extension Setup

You can get a signed version of this extension from the [MoneyMoney Extensions](https://moneymoney-app.com/extensions/) page

Once downloaded, move `Cryptopia.lua` to your MoneyMoney Extensions folder.

## Account Setup

### Cryptopia

1. Log in to your Cryptopia account
2. Go to [User -> Security] (https://www.cryptopia.co.nz/Security)
3. Enable API 
3. New Key (if not already generated one)
4. Save Changes 

### MoneyMoney

Add a new account (type "Cryptopia Account") and use your Cryptopia API key as username and your Cryptopia API secret as password.

#

based on 
https://github.com/yoyostile/moneymoney-binance
