#!/bin/bash
# big thanks @cyberomanov for some code


function wait_completed_transaction() {
    echo 'wait_completed_transaction'
    HASH=${1}

    TRANSACTION_STATUS="unconfirmed."
    while [[ ${TRANSACTION_STATUS} != "confirmed" ]]; do
        TRANSACTION_STATUS=$(${BIN} wallet:transaction ${HASH} | grep "Status: " | sed "s/Status: //")
        if [[ ${TRANSACTION_STATUS} != "confirmed" ]]; then
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}."
            sleep 10
        else
            echo -e "hash: ${HASH}, transaction status: ${TRANSACTION_STATUS}.\n"
        fi
    done
}


function get_balance() {
    echo 'get_balance'
    ${BIN} wallet:balance | grep -o "[0-9]\+.[0-9]*" | tail -1
}


function mint_asset() {
    echo 'mint_asset'
    RESULT=$(echo "Y" | ${BIN} wallet:mint --name=${IRONFISH_GRAFFITI} --metadata=${IRONFISH_GRAFFITI}  --amount=100 --fee=0.00000001 | tr -d '\0')
    check_result "MINT ASSET" "${RESULT}"
}


function burn_asset() {
    echo 'burn_asset'
    RESULT=$(echo "Y" | ${BIN} wallet:burn --assetId=${IDENTIFIER} --amount=50 --fee=0.00000001 | tr -d '\0')
    check_result "BURN ASSET" "${RESULT}"
}


function send_asset() {
    echo 'send_asset'
    ADDRESS_TO_SEND="dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca"
    RESULT=$(echo "Y" | ${BIN} wallet:send --assetId=${IDENTIFIER} --amount 50 --to ${ADDRESS_TO_SEND} --memo "${IRONFISH_GRAFFITI}" --fee=0.00000001 | tr -d '\0')
    check_result "SEND ASSET" "${RESULT}"
}


function get_transaction_hash() {
    echo 'get_transaction_hash'
    INPUT=${1}
    HASH=$(echo ${INPUT} | grep -Eo "Transaction Hash: [a-z0-9]*" | sed "s/Transaction Hash: //")
    echo ${HASH}
}


function check_result() {
    echo 'check_result'
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


function wait_successfull_transaction() {
    echo 'wait_successfull_transaction'
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


function download_scripts() {
    echo 'download_scripts'
	rm -rf $HOME/ironfish-scripts
	mkdir $HOME/ironfish-scripts
	
	wget -q -O $HOME/ironfish-scripts/faucet.sh https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/ironfish_faucet.sh
	chmod u+x $HOME/ironfish-scripts/faucet.sh
}

function copy_files_to_container() {
    echo 'copy_files_to_container'
	DOCKER_CONTAINER=$(docker ps | grep ironfish | awk '{ print $1 }')
	docker cp ./ironfish-scripts/faucet.sh $DOCKER_CONTAINER:/usr/src/app/faucet.sh
	docker cp ./.profile $DOCKER_CONTAINER:/usr/src/app/.ironfish_profile
}

cd $HOME
while true
do
	source .profile
    apt install bc -y
    BIN=$(get_binary)
    IRONFISH_GRAFFITI=$(echo ${BIN} config | grep blockGraffiti | awk -F'"' '{ print $4 }')
    echo "Graffiti ${IRONFISH_GRAFFITI}"
	if [ $(echo "$(get_balance) < 0.00000003" | bc ) -eq 1 ]; then
        DOCKER_CONTAINER=$(docker ps | grep ironfish | awk '{ print $1 }')
		download_scripts
		copy_files_to_container
		docker exec -it ${DOCKER_CONTAINER} sh faucet.sh
        rm -rf ironfish-scripts
	fi
	wait_successfull_transaction "mint_asset"
	wait_successfull_transaction "burn_asset"
	wait_successfull_transaction "send_asset"
	
	date=$(date +"%H:%M")
	echo "Last Update: ${date}"
	printf "Sleep 3.5 days\n"
	printf "with love by @ipohosov.\n"
	sleep 3.5d
done