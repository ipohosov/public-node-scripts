#! /usr/bin/bash
# Thanks @cyberomanov

function wait_transaction_confirmation() {
    function_name=${1,,}
    TRANSACTION_STATUS="unconfirmed"
    time_logs "Verify the ${function_name} transaction."
    sleep 10s
    while [[ ${TRANSACTION_STATUS} != "confirmed" ]] && [[ ${TRANSACTION_STATUS} != "expired" ]]; do
        OUTPUT="$(${BIN} wallet:transactions | sed -n '3 p')"
        array=($OUTPUT)
        TRANSACTION_STATUS="${array[4]}"
        if [[ ${TRANSACTION_STATUS} == "unconfirmed" ]] || [[ ${TRANSACTION_STATUS} == "pending" ]]; then
            time_logs "Status: ${TRANSACTION_STATUS}."
            sleep 15s
        elif [[ ${TRANSACTION_STATUS} == "confirmed" ]]; then
            time_logs "Status: ${TRANSACTION_STATUS}.\n"
        elif [[ ${TRANSACTION_STATUS} == "expired" ]]; then
            time_logs "Status: ${TRANSACTION_STATUS}.\n\n"
            time_logs "This is not okay, starting from zero.\n"
        else
            time_logs "Status: ${TRANSACTION_STATUS}.\n\n"
            time_logs "I don't know what is the status. Please, retry later."
        fi
    done
}

function time_logs() {
  logs=${1}
  time="[ $(date +"%d-%m-%y | %T") ]"
  echo -e "${time} ${logs}"
}

function get_balance() {
    ${BIN} wallet:balance | grep -o "[0-9]\+.[0-9]*" | tail -1
}

function faucet_assets() {
  echo -e "\n-------------------- [ FAUCET ASSET ] --------------------\n"
    time_logs "---ATTENTION: YOU DON'T NEED TO ENTER YOUR EMAIL---"
    RESULT=$(echo -e "\n\n" | ${BIN} faucet)
    check_results "FAUCET" "${RESULT}"
}

function mint_asset() {
    echo -e "\n-------------------- [ MINT ASSET ] --------------------\n"
    RESULT=$(${BIN} wallet:mint -a 10 -f "${NODE_NAME}" -m "${GRAFFITI}" -n "${GRAFFITI}" -o 0.00000001 --confirm | tr -d '\0')
    check_results "MINT" "${RESULT}"
}

function burn_asset() {
    echo -e "\n-------------------- [ BURN ASSET ] --------------------\n"
    RESULT=$(${BIN} wallet:burn -a 5 -f "${NODE_NAME}" -i "${IDENTIFIER}" -o 0.00000001 --confirm | tr -d '\0')
    check_results "BURN" "${RESULT}"
}

function send_asset() {
    echo -e "\n-------------------- [ SEND ASSET ] --------------------\n"
    ADDRESS_TO_SEND="dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca"
    RESULT=$(${BIN} wallet:send -a 5 -f "${NODE_NAME}" -i "${IDENTIFIER}" -t ${ADDRESS_TO_SEND} -o 0.00000001 --confirm | tr -d '\0')
    check_results "SEND" "${RESULT}"
}

function check_results() {
    FUNCTION_NAME=${1}
    FUNCTION_RESULT=${2}

    if [[ ${FUNCTION_RESULT} == *"Transaction Hash"* || ${FUNCTION_RESULT} == *"Congratulations"* ]]; then
        echo -e "\n-------------------- [ ${FUNCTION_NAME} | SUCCESS ] --------------------\n"
        wait_transaction_confirmation "${FUNCTION_NAME}"
        if [[ ${FUNCTION_NAME} == "MINT" ]]; then
            IDENTIFIER=$(echo "${RESULT}" | grep -Eo "Asset Identifier: [a-z0-9]*" | sed "s/Asset Identifier: //")
        fi
    else
        echo -e "\n\n-------------------- [ ${FUNCTION_NAME} | FAIL ] --------------------\n\n${FUNCTION_RESULT}"
        if [[ ${FUNCTION_NAME} == "FAUCET" ]]; then
            time_logs "The faucet was failed. Please ask the assets in discord."
        else
            time_logs "The script was failed. Please check your transactions status(ironfish wallet:transactions)"
        fi
        exit 0
    fi
}

function get_binary() {
    BINARY=$(which ironfish)
    if [[ ${BINARY} == "" ]]; then
        CONTAINER_NAME=$(docker ps | grep ironfish | grep -wv run | awk '{ print $1 }')
        DOCKER_TEST=$(docker exec -it "${CONTAINER_NAME}" ironfish)
        if [[ ${DOCKER_TEST} == *"Error"* ]]; then
            time_logs "I don't know where is your 'ironfish' binary. You can't use this script."
        else
            BINARY="docker exec -i ${CONTAINER_NAME} ironfish"
        fi
    fi
    echo "${BINARY}"
}

cd "$HOME" || exit

time_logs "Start script with Ironfish quests(mint, burn, send)."

BIN=$(get_binary)
# shellcheck disable=SC2001,SC2005
GRAFFITI=$(echo "$(${BIN} config:get blockGraffiti)" | sed 's/\"//g')
# shellcheck disable=SC2001,SC2005
NODE_NAME=$(echo "$(${BIN} config:get nodeName)" | sed 's/\"//g')

if [ $(echo "$(get_balance) < 0.00000003" | bc ) -eq 1 ]; then
    faucet_assets
fi

mint_asset
burn_asset
send_asset

time_logs "Mint, burn and send assets were finished successfully with love by @mplife."