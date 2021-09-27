# Minting Script for Cardano NFTs

## Setup
I am using Linux so I add the following to ~/.bashrc, inserting your own locations:

```
export PAYMENT_ADDR=$(cat <path to address file>)
export PAYMENT_KEY="<path to signing key>"
export RECEIVER_ADDRESS="<address thats receiving the token>"
```

# Scripts
The rest is basically the script from [the Cardano Developer docs](https://developers.cardano.org/docs/native-tokens/minting-nfts) will just some minor personal updates. I did put the policy stuff in its own file to make it easier. 

Hopefully I'll add to this so that I can loop over filenames and get the information for the metadata instead of having so many inputs and running it manually for each one.



