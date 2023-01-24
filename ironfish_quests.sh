#/usr/bin/bash
# Thanks @cyberomanov

function WaitTransactionToBeCompleted() {
    HASH=${1}

    TRANSACTION_STATUS="unconfirmed."
    while [[ ${TRANSACTION_STATUS} != "confirmed" ]] && [[ ${TRANSACTION_STATUS} != "expired" ]]; do
        TRANSACTION_STATUS=$(${BIN} wallet:transaction ${HASH} | grep "Status: " | sed "s/Status: //")
        if [[ ${TRANSACTION_STATUS} == "unconfirmed" ]] || [[ ${TRANSACTION_STATUS} == "pending" ]]; then
            echo -e "hash: ${HASH}, status: ${TRANSACTION_STATUS}."
            sleep 20
        elif [[ ${TRANSACTION_STATUS} == "confirmed" ]]; then
            echo -e "hash: ${HASH}, status: ${TRANSACTION_STATUS}.\n"
        elif [[ ${TRANSACTION_STATUS} == "expired" ]]; then
            echo -e "hash: ${HASH}, status: ${TRANSACTION_STATUS}.\n\nThis is not okay, starting from zero.\n"
        else
            echo -e "hash: ${HASH}, status: ${TRANSACTION_STATUS}.\n\nUnknown status. Please start from zero.\n"
        fi
    done
}


function GetBalanceFunc() {
    if [[ ${1} == '' ]]; then
        ${BIN} wallet:balance | grep -o "[0-9]\+.[0-9]*" | tail -1
    else
        ${BIN} wallet:balance --assetId=${1} | grep -Eo "[0-9]+([.][0-9]+)?" | tail -1
    fi
}


function MintFunc() {
    echo -e "\n-------------------- [ MINT ASSET ] --------------------\n"
    RESULT=$(${BIN} wallet:mint -a 10 -f ${NODE_NAME} -m ${GRAFFITI} -n ${GRAFFITI} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "MINT" "${RESULT}"
}


function BurnFunc() {
    echo -e "\n-------------------- [ BURN ASSET ] --------------------\n"
    RESULT=$(${BIN} wallet:burn -a 5 -f ${NODE_NAME} -i ${IDENTIFIER} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "BURN" "${RESULT}"
}


function SendFunc() {
    echo -e "\n-------------------- [ SEND ASSET ] --------------------\n"
    ADDRESS_TO_SEND="dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca"
    RESULT=$(${BIN} wallet:send -a 5 -f ${NODE_NAME} -i ${IDENTIFIER} -t ${ADDRESS_TO_SEND} -o 0.00000001 --confirm | tr -d '\0')
    CheckResultFunc "SEND" "${RESULT}"
}


function FaucetFunc() {
    echo -e "\n-------------------- [ FAUCET ASSET ] --------------------\n"
    RESULT=$(echo -e "${IRONFISH_EMAIL}\n\n" | ${BIN} faucet | tr -d '\0')
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
            echo -e "\n-------------------- [ ${FUNCTION_NAME} | SUCCESS ] --------------------\n"
            WALLET_BALANCE=$(GetBalanceFunc)
            echo -e "Wallet balance: ${WALLET_BALANCE}."
            while [[ $(echo "${WALLET_BALANCE} < 0.00000003" | bc ) -eq 1 ]]; do
                echo -e "Waiting..."
                sleep 15
                WALLET_BALANCE=$(GetBalanceFunc)
                echo -e "Wallet balance: ${WALLET_BALANCE}."
            done
        else
            echo -e "\n-------------------- [ ${FUNCTION_NAME} | FAIL ] --------------------\n${FUNCTION_RESULT}"
            echo -e "The script was failed. Please check logs and try later."
            exit 0
        fi
    elif [[ ${FUNCTION_RESULT} == *"Transaction Hash"* ]]; then
        FUNC_RESULT="success"
        echo -e "\n-------------------- [ ${FUNCTION_NAME} | SUCCESS ] --------------------\n"
        WaitTransactionToBeCompleted $(GetTransactionHashFunc "${FUNCTION_RESULT}")

        if [[ ${FUNCTION_NAME} == "MINT" ]]; then
            IDENTIFIER=$(echo ${RESULT} | grep -Eo "Asset Identifier: [a-z0-9]*" | sed "s/Asset Identifier: //")
        fi
    else
        echo -e "\n-------------------- [ ${FUNCTION_NAME} | FAIL ] --------------------\n${FUNCTION_RESULT}"
        echo -e "The script was failed. Please check logs and try later."
        exit 0
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

BIN=$(GetBinaryFunc)
GRAFFITI=$(echo $(${BIN} config:get blockGraffiti) | sed 's/\"//g')
NODE_NAME=$(echo $(${BIN} config:get nodeName) | sed 's/\"//g')

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
fi

echo "\n Mint, burn and send assets were fisnished succsessfully with love by @mplife"