#!/bin/bash

set -e
set -o pipefail

if [ -z $9 ]; then

    echo 'USAGE: ./smc-deploy.sh --payer-addr <wallet address to pay for init> --payer-keys <wallet keys path> --abi <SafeMultisigWallet.abi.json path> --stdlib <stdlib_sol.tvm path> <source file>'
    echo 'EXAMPLE: ./smc-deploy.sh --payer-addr 0:af1eec292203b858a374c06992e37d6a3df90b34e2c5362dc5f332cf41b4d53e --payer-keys ./keys.json --abi ../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json --stdlib ../TON-Solidity-Compiler/lib/stdlib_sol.tvm wallet.sol'

else

    contract_name=`basename $9 .sol`
    solc $9
    tvc=`tvm_linker compile $contract_name.code --lib $8 | grep 'Saved contract to file' | awk '{print $NF}'`
    echo $tvc
    contract_address=`tonos-cli genaddr $tvc $contract_name.abi.json --genkey $contract_name.keys.json | grep 'Raw address' | awk '{print $NF}'`
    # Change gen key to set key if needed
    echo $contract_address > $contract_name.addr
    tonos-cli call "$2" submitTransaction "{\"dest\":\"$contract_address\",\"value\":1000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $6 --sign $4
    tonos-cli deploy --abi $contract_name.abi.json --sign $contract_name.keys.json $tvc {}

fi
