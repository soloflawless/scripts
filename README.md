# Minting Script for Cardano NFTs

## Setup
I am using Linux so I add the following to ~/.bashrc, inserting your own locations:

```bash
export PAYMENT_ADDR=$(cat <path to address file>)
export PAYMENT_KEY="<path to signing key>"
export RECEIVER_ADDRESS="<address thats receiving the token>"
```

# Scripts
The rest is basically the script from [the Cardano Developer docs](https://developers.cardano.org/docs/native-tokens/minting-nfts) will just some minor personal updates. I did put the policy stuff in its own file to make it easier. 

Hopefully I'll add to this so that I can loop over filenames and get the information for the metadata instead of having so many inputs and running it manually for each one.

## Policy
Takes on argument thats the duration of the policy
```bash
duration=$1
...
slotnumber=$(expr $(cardano-cli query tip --mainnet | jq .slot?) + $duration)

```

## Arguments
```bash
# assetname appended to transaction
assetname=$1
echo "Token Name: "$assetname
# ipfs location - hash only no ipfs://
ipfs_hash=$2
echo "IPFS Hash: "$ipfs_hash
# description for metadata
description=$3
echo "description: "$description
# id for metadata
id=$4
echo "ID: "$id
# Token name for metadata
name=$5
echo "Name: "$name
```

## TX
I am using one wallet to pay and one to receive the tokens with all the change going to the paying wallet

```bash
cardano-cli transaction build-raw \
--fee $fee  \
--tx-in $txhash#$txix  \
--tx-out $receiver_address+2000000+"$tokenamount $policyid.$assetname" \
--tx-out $PAYMENT_ADDR+$output \
--mint="$tokenamount $policyid.$assetname" \
--minting-script-file $script \
--metadata-json-file metadata.json  \
--invalid-hereafter $slotnumber \
--out-file matx.raw
```

I don't have the minimum tx amount figured out yet so I add 2 ADA which is in the first --tx-out above and comes out of the change. Hopefully I'll learn how to calculate the actual amount and add that in.
```bash
output=$(expr $funds - $fee - 2000000)
```

As I'm learning I've found it helpful to preview the metadata before I do the damn thing.
```bash
# Preview metadata b4 mint
cat metadata.json

# Mint or not?
read -p "Mint token? [y,n]" mint 
case $mint in  
  y|Y) cardano-cli transaction submit --tx-file matx.signed --mainnet ;; 
  n|N) echo "Transaction not submitted" && exit;; 
  *) echo "Not an option" && exit ;; 
esac
```