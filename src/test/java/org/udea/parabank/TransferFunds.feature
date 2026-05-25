@parabank_transfer
Feature: Transfer funds in Parabank

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def val_fromAccountId = '13344'
    * def val_toAccountId = '13455'
    * def fakerObj = new faker()
    * def val_amount = fakerObj.number().numberBetween(1, 200)
    * def val_fromAccountIdError = fakerObj.number().randomNumber(6, true)
    * def val_toAccountIdError = fakerObj.number().randomNumber(6, true)

  Scenario: Transfer funds and validate transaction in ledger history
    # Step 1: Execute transfer
    Given path 'transfer'
    And param fromAccountId = val_fromAccountId
    And param toAccountId = val_toAccountId
    And param amount = 50
    When method POST
    Then status 200
    And match response contains 'Successfully transferred'
    
    * def responseText = response
    * print 'Transfer Response:', responseText
    
    # Step 2: Get transaction history for destination account (FORCE JSON)
    Given path 'accounts', val_toAccountId, 'transactions'
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match response == '#array'
    
    # Step 3: Validate last transaction using JSONPath
    * def lastTransaction = response[response.length - 1]
    * print 'Last Transaction:', lastTransaction
    
    # Step 4: Verify transaction details
    And match lastTransaction.amount == 50
    And match lastTransaction.type == 'Credit'
    And match lastTransaction.accountId == parseInt(val_toAccountId)
    
    # Step 5: Validate transaction ID exists
    And match lastTransaction.id == '#number'
    And match lastTransaction.id == '#? _ > 0'

  Scenario: Validate transaction consistency between sender and receiver
    # Step 1: Get initial balance of destination account
    Given path 'accounts', val_toAccountId
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def initialBalance = response.balance
    * print 'Initial Balance (To Account):', initialBalance
    
    # Step 2: Execute transfer
    Given path 'transfer'
    And param fromAccountId = val_fromAccountId
    And param toAccountId = val_toAccountId
    And param amount = 50
    When method POST
    Then status 200
    
    # Step 3: Get updated balance (FORCE JSON)
    Given path 'accounts', val_toAccountId
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def finalBalance = response.balance
    * print 'Final Balance (To Account):', finalBalance
    
    # Step 4: Validate balance increased by transfer amount
    * def expectedBalance = initialBalance + 50
    And match finalBalance == expectedBalance
    
    # Step 5: Verify transaction in history matches the amount
    Given path 'accounts', val_toAccountId, 'transactions'
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def creditTransactions = karate.filter(response, function(x){ return x.type == 'Credit' && x.amount == 50 })
    And match creditTransactions == '#[_ > 0]'

  Scenario: Successful Transfer (Original Test)
    Given path 'transfer'
    And param fromAccountId = val_fromAccountId
    And param toAccountId = val_toAccountId
    And param amount = val_amount
    When method POST
    Then status 200
    And match response == "Successfully transferred $" + val_amount + " from account #" + val_fromAccountId + " to account #" + val_toAccountId

  Scenario: Transfer Failed - Not found account
    Given path 'transfer'
    And param fromAccountId = val_fromAccountIdError
    And param toAccountId = val_toAccountIdError
    And param amount = val_amount
    When method POST
    Then status 400
  And match response contains val_fromAccountIdError
  And match response contains val_toAccountIdError