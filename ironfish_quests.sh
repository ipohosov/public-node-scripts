#/usr/bin/bash
# Thanks @cyberomanov

function WaitTransactionToBeCompleted() {
    HASH=${1}

    TRANSACTION_STATUS="unconfirmed."
    while [[ ${TRANSACTION_STATUS} != "confirmed" ]]; do
        TRANSACTION_STATUS=$(ironfish wallet:transaction ${HASH} | grep "Status: " | sed "s/Status: //")
        if [[ ${TRANSACTION_STATUS} != "confirmed" ]]; then
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}."
            sleep 10
        else
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}.\n"
        fi
    done
}


function GetBalanceFunc() {
    ironfish wallet:balance | grep -o "[0-9]\+.[0-9]*" | tail -1
}


function MintFunc() {
    RESULT=$(ironfish wallet:mint -a 10 -f ${NODE_NAME} -m ${GRAFFITI} -n ${GRAFFITI} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "MINT" "${RESULT}"
}


function BurnFunc() {
    RESULT=$(ironfish wallet:burn -a 5 -f ${NODE_NAME} -i ${IDENTIFIER} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "BURN" "${RESULT}"
}


function SendFunc() {
    ADDRESS_TO_SEND="dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca"
    RESULT=$(ironfish wallet:send -a 5 -f ${NODE_NAME} -i ${IDENTIFIER} -t ${ADDRESS_TO_SEND} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "SEND" "${RESULT}"
}


function FaucetFunc() {
    BIN=$(GetBinaryFunc)
    RESULT=$(echo $IRONFISH_EMAIL | ${BIN} faucet | tr -d '\0')
    CheckResultFunc "FAUCET" "${RESULT}"
}


function GetTransactionHashFunc() {
    INPUT=${1}
    HASH=$(echo ${INPUT} | grep -Eo "Transaction Hash: [a-z0-9]*" | sed "s/Transaction Hash: //")
    echo ${HASH}
}


function CheckResultFunc() {
    FUNC_RESULT="fail"

    FUNCTION_NAME=${1}
    FUNCTION_RESULT=${2}

    if [[ ${FUNCTION_NAME} == "FAUCET" ]]; then
        if [[ ${FUNCTION_RESULT} == *"Congratulations! The Iron Fish Faucet just added your request to the queue!"* ]]; then
            FUNC_RESULT="success"
            echo -e "\n/////////////////// [ ${FUNCTION_NAME} | SUCCESS ] ///////////////////\n"
            WALLET_BALANCE=$(GetBalanceFunc)
            echo -e "Wallet balance: ${WALLET_BALANCE}."
            while [[ $(echo "${WALLET_BALANCE} < 0.00000003" | bc ) -eq 1 ]]; do
                echo -e "Waiting..."
                sleep 15
                WALLET_BALANCE=$(GetBalanceFunc)
                echo -e "Wallet balance: ${WALLET_BALANCE}."
            done
        else
            echo -e "\n/////////////////// [ ${FUNCTION_NAME} | FAIL ] ///////////////////\n${FUNCTION_RESULT}"
        fi
    elif [[ ${FUNCTION_RESULT} == *"Transaction Hash"* ]]; then
        FUNC_RESULT="success"
        echo -e "\n/////////////////// [ ${FUNCTION_NAME} | SUCCESS ] ///////////////////\n"
        WaitTransactionToBeCompleted $(GetTransactionHashFunc "${FUNCTION_RESULT}")

        if [[ ${FUNCTION_NAME} == "MINT" ]]; then
            IDENTIFIER=$(echo ${RESULT} | grep -Eo "Asset Identifier: [a-z0-9]*" | sed "s/Asset Identifier: //")
        fi
    else
        echo -e "\n/////////////////// [ ${FUNCTION_NAME} | FAIL ] ///////////////////\n${FUNCTION_RESULT}"
    fi
}


function GetBinaryFunc() {
    BINARY=$(which ironfish)
    if [[ ${BINARY} == "" ]]; then
        DOCKER_CONTAINER=$(docker ps | grep ironfish | awk '{ print $1 }')
        DOCKER_TEST=$(docker exec -it ${DOCKER_CONTAINER} ironfish)
        if [[ ${DOCKER_TEST} == *"Error"* ]]; then
            echo "i don't know where is your 'ironfish' binary. set it manually."
        else
            BINARY="docker exec -i ${DOCKER_CONTAINER} ironfish"
        fi
    fi
    echo ${BINARY}
}

cd $HOME
apt install bc -y

GRAFFITI=$(echo $(ironfish config:get blockGraffiti) | sed 's/\"//g')
NODE_NAME=$(echo $(ironfish config:get nodeName) | sed 's/\"//g')

if [ $(echo "$(GetBalanceFunc) < 0.00000003" | bc ) -eq 1 ]; then
    FaucetFunc
fi
if [ $(echo "$(GetBalanceFunc) > 0.00000002" | bc ) -eq 1 ]; then
    MintFunc
    BurnFunc
    SendFunc
else
    echo "Not enough balance. Looks like faucet doesn't work at that moment."
    echo "Minimum required: \$IRON 0.00000003, but you have only: \$IRON $(GetBalanceFunc)."

echo -e "with love by @ipohosov."