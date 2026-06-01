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

    Given path 'transfer'
    And param fromAccountId = val_fromAccountId
    And param toAccountId = val_toAccountId
    And param amount = 50
    When method POST
    Then status 200

    # Criterio de aceptación: capturar ID de la transacción resultante
    * def transactionId = response.id
    And match transactionId == '#number'

    Given path 'accounts', val_toAccountId, 'transactions'
    And header Accept = 'application/json'
    When method GET
    Then status 200

    * def lastTransaction = response[response.length - 1]

    And match lastTransaction.amount == 50
    And match lastTransaction.type == 'Credit'
    And match lastTransaction.accountId == parseInt(val_toAccountId)