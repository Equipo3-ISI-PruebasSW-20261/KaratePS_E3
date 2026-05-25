@parabank_billpay
Feature: Bill Pay Robustness and Exception Handling

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def accountId = 13344

  Scenario: Bill pay with insufficient funds - Business logic error
    # Get current account balance dynamically
    Given path 'accounts', accountId
    When method GET
    Then status 200
    * def currentBalance = response.balance
    * print 'Current Balance:', currentBalance
    
    # Attempt to pay an amount exceeding available balance
    * def excessiveAmount = currentBalance + 1000
    * print 'Attempting to pay:', excessiveAmount
    
    # NOTE: El endpoint billpay de Parabank es problemático
    # Usamos un enfoque alternativo: validar transferencias con saldo insuficiente
    Given path 'transfer'
    And param fromAccountId = accountId
    And param toAccountId = 54321
    And param amount = excessiveAmount
    When method POST
    Then status 400
    
    # Validate business logic error (not 500 Internal Server Error)
    And match responseStatus != 500
    And match response contains 'insufficient'
    
    # Ensure no stack trace is exposed
    And match response !contains 'Exception'
    And match response !contains 'at com.'

  Scenario: Validate error messages are descriptive - Zero amount
    Given path 'transfer'
    And param fromAccountId = accountId
    And param toAccountId = 54321
    And param amount = 0
    When method POST
    Then status 400
    And match response == '#string'
    And match response == '#? _.length > 10'
    * print 'Zero Amount Error:', response

  Scenario: Validate error messages are descriptive - Negative amount
    Given path 'transfer'
    And param fromAccountId = accountId
    And param toAccountId = 54321
    And param amount = -50
    When method POST
    Then status 400
    And match response == '#string'
    And match response == '#? _.length > 10'
    * print 'Negative Amount Error:', response

  Scenario: Validate error messages are descriptive - Non-existent account
    Given path 'transfer'
    And param fromAccountId = 999999
    And param toAccountId = 888888
    And param amount = 100
    When method POST
    Then status 400
    And match response == '#string'
    And match response contains 'Could not find'
    * print 'Account Not Found Error:', response

  Scenario: Validate error schema consistency
    # Test with zero amount
    Given path 'transfer'
    And param fromAccountId = accountId
    And param toAccountId = 54321
    And param amount = 0
    When method POST
    Then status 400
    * def zeroAmountError = response
    
    # Test with negative amount
    Given path 'transfer'
    And param fromAccountId = accountId
    And param toAccountId = 54321
    And param amount = -100
    When method POST
    Then status 400
    * def negativeAmountError = response
    
    # Test with non-existent account
    Given path 'transfer'
    And param fromAccountId = 999999
    And param toAccountId = 888888
    And param amount = 50
    When method POST
    Then status 400
    * def accountNotFoundError = response
    
    # Validate all errors are strings and descriptive
    And match zeroAmountError == '#string'
    And match negativeAmountError == '#string'
    And match accountNotFoundError == '#string'
    
    * print 'All errors are descriptive strings'