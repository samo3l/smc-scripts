#!/bin/bash

set -e
set -o pipefail

stdlib="../TON-Solidity-Compiler/lib/stdlib_sol.tvm"

if [ -z $5 ]; then

    echo 'USAGE: ./smc-update.sh --addr <contract to update> --sign <contract keys path> <source-file>'
    echo 'EXAMPLE: ./smc-update.sh --addr `cat wallet.addr` --sign wallet.keys.json wallet.sol'

else

    contract_name=`basename $5 .sol`
    solc $5
    tvc=`tvm_linker compile $contract_name.code --lib $stdlib | grep 'Saved contract to file' | awk '{print $NF}'`
    newcode=`tvm_linker decode --tvc $tvc | grep 'code:' | awk '{print $NF}'`
    tonos-cli call $2 setCode "{\"newcode\":\"$newcode\"}" --abi $contract_name.abi.json --sign $4

fi
