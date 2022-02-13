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

        const marketplace_contract = await deploy_contract('Marketplace', [
            token_contract.options.address
        ])

        const manager_contract = deploy_contract('Manager', [
            marketplace_contract.options.address
        ])

        const freelancer_contract = deploy_contract('Freelancer', [
            "Ion Ionescu",
            "testing",
            marketplace_contract.options.address
        ])

        const evaluator_contract = deploy_contract('Evaluator', [
            "George Popescu",
            "testing",
            marketplace_contract.options.address
        ])

        const funder_contract = deploy_contract('Funder', [
            marketplace_contract.options.address
        ])
})

deploy_infrastructure()