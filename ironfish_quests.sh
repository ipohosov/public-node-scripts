#!/bin/bash
# big thanks @cyberomanov for some code

exists()
{
  command -v "$1" >/dev/null 2>&1
}

if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi

bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi


function wait_completed_transaction() {
    HASH=${1}

    TRANSACTION_STATUS="unconfirmed."
    while [[ ${TRANSACTION_STATUS} != "confirmed" ]]; do
        TRANSACTION_STATUS=$(${BIN} ironfish wallet:transaction ${HASH} | grep "Status: " | sed "s/Status: //")
        if [[ ${TRANSACTION_STATUS} != "confirmed" ]]; then
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}."
            sleep 10
        else
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}.\n"
        fi
    done
}


function get_balance() {
    ${BIN} ironfish wallet:balance | grep -o "[0-9]\+.[0-9]*" | tail -1
}


function check_result() {
    FUNC_RESULT="fail"

    FUNCTION_NAME=${1}
    FUNCTION_RESULT=${2}

    if [[ ${FUNCTION_RESULT} == *"Transaction Hash"* ]]; then
        FUNC_RESULT="success"
        echo -e "\n/////////////////// [ ${FUNCTION_NAME} | SUCCESS | #${FUNC_TRY} ] ///////////////////\n"
        wait_completed_transaction $(get_transaction_hash "${FUNCTION_RESULT}")

        if [[ ${FUNCTION_NAME} == "MINT" ]]; then
            IDENTIFIER=$(echo ${RESULT} | grep -Eo "Asset Identifier: [a-z0-9]*" | sed "s/Asset Identifier: //")
        fi
    else
        echo -e "\n/////////////////// [ ${FUNCTION_NAME} | FAIL | #${FUNC_TRY} ] ///////////////////\n${FUNCTION_RESULT}"
    fi
}

function mint_asset() {
    RESULT=$(echo "Y" | ${BIN} ironfish wallet:mint --name=${GRAFFITI} --metadata=${GRAFFITI}  --amount=1000 --fee=0.00000001 | tr -d '\0')
    check_result "MINT ASSET" "${RESULT}"
}


function burn_asset() {
    RESULT=$(echo "Y" | ${BIN} ironfish wallet:burn --assetId=${IDENTIFIER} --amount=500 --fee=0.00000001 | tr -d '\0')
    check_result "BURN ASSET" "${RESULT}"
}


function send_asset() {
    ADDRESS_TO_SEND="dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca"
    RESULT=$(echo "Y" | ${BIN} ironfish wallet:send --assetId=${IDENTIFIER} --amount 500 --to ${ADDRESS_TO_SEND} --memo "${GRAFFITI}" --fee=0.00000001 | tr -d '\0')
    check_result "SEND ASSET" "${RESULT}"
}


function get_transaction_hash() {
    INPUT=${1}
    HASH=$(echo ${INPUT} | grep -Eo "Transaction Hash: [a-z0-9]*" | sed "s/Transaction Hash: //")
    echo ${HASH}
}


function download_scripts_and_soft() {
	rm -rf $HOME/ironfish-scripts
	mkdir $HOME/ironfish-scripts
	
	apt install bc -y
	wget -q -O $HOME/ironfish-scripts/faucet.sh https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/ironfish_faucet.sh
	chmod u+x $HOME/ironfish-scripts/faucet.sh
}

function copy_files_to_container() {
	DOCKER_CONTAINER=$(docker ps | grep ironfish | awk '{ print $1 }')
	docker cp ./ironfish-scripts/faucet.sh $DOCKER_CONTAINER:/usr/src/app/faucet.sh
	docker cp ./.profile $DOCKER_CONTAINER:/usr/src/app/.ironfish_profile
}


function wait_successfull_transaction() {
    FUNCTION=${1}

    FUNC_RESULT="fail"
    FUNC_TRY=0

    while [[ ${FUNC_RESULT} == "fail" ]]; do
        FUNC_TRY=$((FUNC_TRY + 1))
        ${FUNCTION}
        sleep 5
    done
}


function get_binary() {
	DOCKER_CONTAINER=$(docker ps | grep ironfish | awk '{ print $1 }')
	BINARY="docker exec -i ${DOCKER_CONTAINER} ironfish"
	echo ${BINARY}
}


cd $HOME
while true
do
	source .profile
	BIN=$(get_binary)
	IRONFISH_WALLET=$(${BIN} ironfish wallet:address | awk -F': ' '{ print $3 }')
	IRONFISH_GRAFFITI=$(${BIN} ironfish config | grep blockGraffiti | awk -F'"' '{ print $4 }')

	if [ $(echo "$(get_balance) < 0.00000003" | bc ) -eq 1 ]; then
		download_scripts_and_soft
		copy_files_to_container
		${BIN} sh faucet.sh
	fi
	wait_successfull_transaction "mint_asset"
	wait_successfull_transaction "burn_asset"
	wait_successfull_transaction "send_asset"
	rm -rf ironfish-scripts

	date=$(date +"%H:%M")
	echo "Last Update: ${date}"
	printf "Sleep 3.5 days\n"
	printf "with love by @ipohosov.\n"
	sleep 3.5d
done