@parabank_transfer_atomic
Feature: Atomic Transfer with Ledger Validation

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def customerId = 12212
    * def fromAccountId = 13344
    * def toAccountId = 13455
    * def transferAmount = 50

  Scenario: Transfer funds and validate transaction in ledger history
    # Step 1: Execute transfer
    Given path 'transfer'
    And param fromAccountId = fromAccountId
    And param toAccountId = toAccountId
    And param amount = transferAmount
    When method POST
    Then status 200
    And match response contains 'Successfully transferred'
    
    # Step 2: Extract transaction details from response
    * def responseText = response
    * print 'Transfer Response:', responseText
    
    # Step 3: Get transaction history for destination account
    Given path 'accounts', toAccountId, 'transactions'
    When method GET
    Then status 200
    And match response == '#array'
    
    # Step 4: Validate last transaction using JSONPath
    * def lastTransaction = response[response.length - 1]
    * print 'Last Transaction:', lastTransaction
    
    # Step 5: Verify transaction details
    And match lastTransaction.amount == transferAmount
    And match lastTransaction.type == 'Credit'
    And match lastTransaction.accountId == toAccountId
    
    # Step 6: Validate transaction ID exists
    And match lastTransaction.id == '#number'
    And match lastTransaction.id == '#? _ > 0'
    
    # Step 7: Verify transaction date
    And match lastTransaction.date == '#string'
    And match lastTransaction.date == '#? _.length > 0'

  Scenario: Validate transaction consistency between sender and receiver
    # Step 1: Get initial balance of destination account
    Given path 'accounts', toAccountId
    When method GET
    Then status 200
    * def initialBalance = response.balance
    * print 'Initial Balance (To Account):', initialBalance
    
    # Step 2: Execute transfer
    Given path 'transfer'
    And param fromAccountId = fromAccountId
    And param toAccountId = toAccountId
    And param amount = transferAmount
    When method POST
    Then status 200
    
    # Step 3: Get updated balance
    Given path 'accounts', toAccountId
    When method GET
    Then status 200
    * def finalBalance = response.balance
    * print 'Final Balance (To Account):', finalBalance
    
    # Step 4: Validate balance increased by transfer amount
    * def expectedBalance = initialBalance + transferAmount
    And match finalBalance == expectedBalance
    
    # Step 5: Verify transaction in history matches the amount
    Given path 'accounts', toAccountId, 'transactions'
    When method GET
    Then status 200
    * def creditTransactions = karate.filter(response, function(x){ return x.type == 'Credit' && x.amount == transferAmount })
    And match creditTransactions == '#[1]'