import {Ed25519Keypair, JsonRpcProvider, RawSigner} from '@mysten/sui.js';
import {uniqueNamesGenerator, adjectives, colors, animals }  from 'unique-names-generator';
import fs from 'fs';
import consoleStamp from 'console-stamp';

consoleStamp(console, {format: ':date(HH:MM:ss)'});

const timeout = ms => new Promise(res => setTimeout(res, ms))
const provider = new JsonRpcProvider(/*'https://rpc.ankr.com/sui_testnet*/'https://fullnode-tokenomics.testnet.sui.io')

function getMnemonics() {
    return fs.readFileSync('mnemonics.txt', 'utf-8').split(/[\n\r]/);
}

function getRandomInt(max) {
    return Math.floor(Math.random() * max);
}

function shuffle(array) {
    let currentIndex = array.length,  randomIndex;
    while (currentIndex != 0) {
        randomIndex = getRandomInt(currentIndex);
        currentIndex--;
        [array[currentIndex], array[randomIndex]] = [array[randomIndex], array[currentIndex]];
    }
    return array;
}

(async () => {

    fs.writeFile('wallets.csv', '', function() {})
    let mnemonics = shuffle(getMnemonics())
    if (mnemonics.length > 0) {
        for (const mnemonic of mnemonics) {
            let trying = 5;
            while(trying > 0){
                try {
                    await playTheGame(mnemonic)
                    trying = 0;
                    await timeout(500 + getRandomInt(1000))
                } catch(err) {
                    if (err.message == "Insufficient balance") trying = 0; else trying--;
                    console.log("\x1b[31m%s\x1b[0m", err.message);
                    await timeout(getRandomInt(1000))
                }
            }
        }
    }
})()

async function playTheGame(mnemonic) {

    let toCsv = []
    const keypair = Ed25519Keypair.deriveKeypair(mnemonic.trim());
    const address = keypair.getPublicKey().toSuiAddress()
    const signer = new RawSigner(keypair, provider);

    console.log('\x1b[33m%s\x1b[0m', "Address: 0x" + address)

    let regData = await getGameInfo(address)
    let balance = await provider.getBalance(address)

    toCsv.push(mnemonic)
    toCsv.push(address)
    toCsv.push(balance.totalBalance)

    if (balance.totalBalance < 100000000 && !regData) {
        throw new Error("Insufficient balance");
    }

    let delegations = await getDelegations(address)
    let epoch = await getEpoch()

    if(delegations.length) {
        console.log("withdraw delegations")
        for (const object of delegations) {
            await requestWithdrawDelegation(signer, object)
        }
        await timeout(1000 + getRandomInt(1000))
    }

    if (!regData) {
        console.log("register new name")
        await registerName(signer);
        await timeout(1000 + getRandomInt(1000))
        regData = await getGameInfo(address)
    }

    if (parseInt(regData.details.data.fields.assignment.fields.epoch) != epoch) {
        console.log("press start button")
        await startButton(signer, regData.details.reference.objectId)
        await timeout(1000 + getRandomInt(1000))
        regData = await getGameInfo(address)
    }

    toCsv.push(regData.details.data.fields.name.fields.name)
    toCsv.push(regData.details.data.fields.score)

    let goal = regData.details.data.fields.assignment.fields.goal
    let validator = regData.details.data.fields.assignment.fields.validator

    let already_staked = false
    let stakes = await getStakes(address)

    if(stakes.length) {
        for (const object of stakes) {
            let stake_epoch = parseInt(object.details.data.fields.delegation_request_epoch)
            if(stake_epoch == epoch) {
                already_staked = true
                console.log("already delegated")
            }
        }
    }
    if(!already_staked) {
        let balance = await provider.getBalance(address)
        let stakeSum = parseInt(balance.totalBalance - (balance.totalBalance * (20 + getRandomInt(30)) / 100))
        let goalString = ""
        switch (goal) {
            case 0:
                goalString = "Friend"
                await stakeValidator(signer, validator, stakeSum)
                break
            case 1:
            case 2:
                if(goal == 1) goalString = "Neutral"; else goalString = "Enemy"
                let to_validator = await findNextValidator(validator)
                await stakeValidator(signer, to_validator, stakeSum)
                break
        }
        console.log('\x1b[36m%s\x1b[0m', "Was delegated as " + goalString)
    }
    fs.appendFileSync('wallets.csv', toCsv.join(";") + "\r\n")
}


async function getEpoch() {

    let epochInfo = await provider.getEvents(
        {
            MoveEvent: "0x2::sui_system::SystemEpochInfo"
        },
        null,
        1,
        "descending"
    )
    return parseInt(epochInfo.data[0].event.moveEvent.fields.epoch)
}

async function requestWithdrawDelegation(signer, data) {

    return await signer.executeMoveCall({
        packageObjectId: '0x2',
        module: 'sui_system',
        function: 'request_withdraw_delegation',
        typeArguments: [],
        gasBudget: 100000,
        arguments: [
            "0x5",
            data[0],
            data[1],
        ]
    })
}

async function cancelDelegation(signer, object) {

    return await signer.executeMoveCall({
        packageObjectId: '0x2',
        module: 'sui_system',
        function: 'cancel_delegation_request',
        typeArguments: [],
        gasBudget: 100000,
        arguments: [
            "0x5",
            object.details.data.fields.id.id
        ]
    })
}

async function startButton(signer, userObjectId) {

    return await signer.executeMoveCall({
        packageObjectId: '0x436dfcc34d299f3ad41a3429da4b66f2e627db84',
        module: 'frenemies',
        function: 'update',
        typeArguments: [],
        arguments: [userObjectId, "0x5", "0x3b687296398b01a4054c44a552375fc988992c22"],
        gasBudget: 100000,
    })
}

async function getDelegations(address) {

    let objects = await provider.getObjectsOwnedByAddress(address)
    let staked = []
    for (const object of objects) {
        if (object.type == '0x2::staking_pool::Delegation') {
            var obj =await provider.getObject(object.objectId)
            staked.push([object.objectId, obj.details.data.fields.staked_sui_id])
        }
    }
    return staked
}

async function getStakes(address) {

    let objects = await provider.getObjectsOwnedByAddress(address)
    let staked = []
    for (const object of objects) {
        if (object.type == '0x2::staking_pool::StakedSui') {
            staked.push(await provider.getObject(object.objectId))
        }
    }
    return staked
}

async function getGameInfo(address) {

    let objects = await provider.getObjectsOwnedByAddress(address)
    for (const object of objects) {
        if (object.type == '0x436dfcc34d299f3ad41a3429da4b66f2e627db84::frenemies::Scorecard') {
            return await provider.getObject(object.objectId)
        }
    }
}

async function stakeValidator(signer, validator, stakeSum) {

    let address = await signer.getAddress()
    let objects = await provider.getCoins(address)
    objects.data.sort(function (a, b) {
        return b.balance - a.balance;
    });

    let coins = []
    let balance = 0
    for (const object of objects.data) {
        if (balance < stakeSum) {
            if(object.balance < (stakeSum-balance)) {
                balance += parseInt(object.balance)
            } else {
                balance = stakeSum
            }
            coins.push(object.coinObjectId)
        }
    }

    let result = await signer.paySui({
        inputCoins: coins,
        recipients: ["0x" + address],
        amounts: [stakeSum],
        gasBudget: 100000,
    })

    let objId = result.EffectsCert.effects.effects.created[0].reference.objectId

    return await signer.executeMoveCall({
        packageObjectId: '0x2',
        module: 'sui_system',
        function: 'request_add_delegation_mul_coin',
        typeArguments: [],
        gasBudget: 100000,
        arguments: [
            "0x0000000000000000000000000000000000000005",
            [objId],
            [ stakeSum.toString() ],
            validator
        ],

    })
}

async function findNextValidator(validator) {

    let validators = await provider.getValidators()
    validators.sort(function (a, b) {
        return (b.next_epoch_stake + b.next_epoch_delegation) - (a.next_epoch_stake + a.next_epoch_delegation);
    });
    var id = validators.map(function(obj) { return obj.sui_address; }).indexOf(validator);
    if(id < validators.length-1) {
        id++;
    } else {
        id--;
    }
    return validators[id].sui_address;
}

async function registerName(signer) {

    const shortName = uniqueNamesGenerator({
        dictionaries: [adjectives, animals, colors],
        length: 2,
        separator: "",
        style: 'capital'
    });

    return await signer.executeMoveCall({
        packageObjectId: '0x436dfcc34d299f3ad41a3429da4b66f2e627db84',
        module: 'frenemies',
        function: 'register',
        typeArguments: [],
        arguments: [shortName + (1900 + getRandomInt(120)), "0xef151701ff1f4424faa36aba95c21efdd8d89bf9", "0xc42531c558ded8fcfecb0b0a4b479d9efb14af67", "0x000000000000000000000000000000000000005"],
        gasBudget: 100000,
    })
}