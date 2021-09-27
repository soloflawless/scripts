#!/bin/bash
if [ -e policy/policy.script ]
then
  read -p "A policy already exists. Delete it? [y,n]" delete_policy
  case $delete_policy in  
    y|Y) rm policy/policy.script && rm policy/policyID && echo "Deleted";; 
    n|N) echo "Policy not deleted" && exit ;; 
    *) echo "Not an option" && exit ;; 
  esac
fi

cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey

cardano-cli query protocol-parameters --mainnet --out-file protocol.json


slotnumber=$(expr $(cardano-cli query tip --mainnet | jq .slot?) + 100000)

echo "{" >> policy/policy.script
echo "  \"type\": \"all\"," >> policy/policy.script
echo "  \"scripts\":" >> policy/policy.script
echo "  [" >> policy/policy.script
echo "   {" >> policy/policy.script
echo "     \"type\": \"before\"," >> policy/policy.script
echo "     \"slot\": $slotnumber" >> policy/policy.script
echo "   }," >> policy/policy.script
echo "   {" >> policy/policy.script
echo "     \"type\": \"sig\"," >> policy/policy.script
echo "     \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"" >> policy/policy.script
echo "   }" >> policy/policy.script
echo "  ]" >> policy/policy.script
echo "}" >> policy/policy.script

$(cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID)
echo "New policy and ID file created"