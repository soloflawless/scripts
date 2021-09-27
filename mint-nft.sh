#!/bin/bash

if [ -e metadata.json ]
then
  rm metadata.json
else
  echo "No existing metadata"
fi

assetname=$1
echo "Token Name: "$assetname
ipfs_hash=$2
echo "IPFS Hash: "$ipfs_hash
description=$3
echo "description: "$description
id=$4
echo "ID: "$id
name=$5
echo "Name: "$name

tokenamount="1"
fee="0"
output="0"

# wallet the token goes to 
receiver_address=$RECEIVER_ADDRESS
wallet=$(cardano-cli query utxo --address $PAYMENT_ADDR --mainnet)

# I'm always using and replacing the only utxo in this particualar wallet, 
# not ideal
txhash=$(echo $wallet | tr -s ' ' | cut -d ' ' -f 5)
echo $txhash
txix=$(echo $wallet | tr -s ' ' | cut -d ' ' -f 6)
echo $txix

funds=$(echo $wallet | tr -s ' ' | cut -d ' ' -f 7)
slotnumber=$(cat policy/policy.script | jq .scripts[0].slot)
script="policy/policy.script"
policyid=$(cat policy/policyID)
echo "Policy ID: "$policyid

echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$policyid\": {" >> metadata.json
echo "      \"$(echo $assetname)\": {" >> metadata.json
echo "        \"description\": \"$description\"," >> metadata.json
echo "        \"name\": \"$name\"," >> metadata.json
echo "        \"id\": \"$id\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json

cat metadata.json

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

fee=$(cardano-cli transaction calculate-min-fee --tx-body-file matx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 1 --mainnet --protocol-params-file protocol.json | cut -d " " -f1)

# worth adding an actual minimum ADA calculation
output=$(expr $funds - $fee - 2000000)

echo "Funds: "$funds
echo "Fee: "$fee
echo "Change: "$output

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

cardano-cli transaction sign  \
--signing-key-file $PAYMENT_KEYFILE  \
--signing-key-file policy/policy.skey  \
--mainnet --tx-body-file matx.raw  \
--out-file matx.signed

# Preview metadata b4 mint
cat metadata.json

# Mint or not?
read -p "Mint token? [y,n]" mint 
case $mint in  
  y|Y) cardano-cli transaction submit --tx-file matx.signed --mainnet ;; 
  n|N) echo "Transaction not submitted" && exit;; 
  *) echo "Not an option" && exit ;; 
esac




