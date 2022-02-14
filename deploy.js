// Right click on the script name and hit "Run" to execute

deploy_contract = (async (contractName, constructorArgs) => {    

    try {        
        const artifactsPath = `browser/contracts/artifacts/${contractName}.json`

        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
        const accounts = await web3.eth.getAccounts()
    
        let contract = new web3.eth.Contract(metadata.abi)
    
        contract = contract.deploy({
            data: metadata.data.bytecode.object,
            arguments: constructorArgs
        })
    
        const newContractInstance = await contract.send({
            from: accounts[0],
            gas: 300000000,
            gasPrice: '30000000000'
        })

        console.log(`Contract ${contractName} deployed at address: `, newContractInstance.options.address)

        return newContractInstance;

    } catch (e) {
        console.log(e.message)
    }
  })

deploy_infrastructure = (async () => {
        const token_contract = await deploy_contract('Token', [])
        const accounts = await web3.eth.getAccounts()

        const marketplace_contract = await deploy_contract('Marketplace', [
            token_contract.options.address
        ])

        const manager_contract = deploy_contract('Manager', [
            marketplace_contract.options.address,
            token_contract.options.address
        ])

        const freelancer_contract = deploy_contract('Freelancer', [
            "Ion Ionescu",
            "testing",
            marketplace_contract.options.address,
            token_contract.options.address
        ])

        const evaluator_contract = deploy_contract('Evaluator', [
            "George Popescu",
            "testing",
            marketplace_contract.options.address
        ])

        const funder_contract = deploy_contract('Funder', [
            marketplace_contract.options.address,
            token_contract.options.address
        ])

        await funder_contract
        console.log('Deployed contracts')

        // Not working. If you comment this, the last call in this function will work.
        // Check https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#methods-mymethod-call
        // This is not printing anything on any promise or callback. dunno what's wrong.
        // Note that .send can change internal contract state. .call can't.
        manager_contract.methods.create_task(
            marketplace_contract.options.address,
            "This is the first task on the marketplace!", "Tech",
            20, 10)
        .send({from: accounts[0]}, function (err, res) {
            console.log(`Err: ${err}`)
            console.log(`Res: ${res}`)
        }).then(function(receipt) {
            console.log(`Then: ${receipt}`)
        }).on('receipt', function (res) {
           console.log('----- Created task with id 1 ------')
           console.log(`${JSON.stringify(res, null, 4)}`)
        }).on('error', function(error, receipt) {
            console.log(`Error: ${error}`)
            console.log(`Receipt: ${receipt}`)
        })

        // funder_contract.methods.funder_task(1, 100).send({from: accounts[0]}).on('receipt', function (res) {
        //    console.log('----- Funded task with id 1 ------')
        //    console.log(`${JSON.stringify(res, null, 4)}`)
        // })

        // freelancer_contract.methods.subscribe_to_task(1).send({from: accounts[0]}).on('receipt', function (res) {
        //    console.log('----- Freelancer subscribed to task 1 ------')
        //    console.log(`${JSON.stringify(res, null, 4)}`)
        // })

        // manager_contract.methods.assign_freelancer(
        //     marketplace_contract.options.address,
        //     1,
        //     evaluator_contract.options.address
        // ).send({from: accounts[0]}).on('receipt', function (res) {
        //    console.log('----- Manager assigned freelancer to task 1 ------')
        //    console.log(`${JSON.stringify(res, null, 4)}`)
        // })

        marketplace_contract.methods.list_tasks().send({from: accounts[0]}).on('receipt', function (res) {
           console.log('----- List tasks after freelancer assignment ------')
           console.log(`${JSON.stringify(res, null, 4)}`)
        })
})

deploy_infrastructure()
