@parabank_billpay
Feature: Bill Pay Robustness and Exception Handling

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def accountId = 13344
    * def payeeName = 'Electric Company'
    * def payeeAddress = '123 Main St'
    * def payeeCity = 'Springfield'
    * def payeeState = 'IL'
    * def payeeZipCode = '62701'
    * def payeePhone = '555-1234'
    * def payeeAccountNumber = '987654321'

  Scenario: Bill pay with insufficient funds - Business logic error
    # Step 1: Get current account balance dynamically
    Given path 'accounts', accountId
    When method GET
    Then status 200
    * def currentBalance = response.balance
    * print 'Current Balance:', currentBalance
    
    # Step 2: Attempt to pay an amount exceeding available balance
    * def excessiveAmount = currentBalance + 1000
    * print 'Attempting to pay:', excessiveAmount
    
    Given path 'billpay'
    And param accountId = accountId
    And param amount = excessiveAmount
    And params { payeeName: '#(payeeName)', 'address.street': '#(payeeAddress)', 'address.city': '#(payeeCity)', 'address.state': '#(payeeState)', 'address.zipCode': '#(payeeZipCode)', phoneNumber: '#(payeePhone)', accountNumber: '#(payeeAccountNumber)' }
    When method POST
    Then status 400
    
    # Step 3: Validate business logic error (not 500 Internal Server Error)
    And match responseStatus != 500
    And match response contains 'insufficient'
    
    # Step 4: Ensure no stack trace is exposed
    And match response !contains 'Exception'
    And match response !contains 'at com.'
    And match response !contains 'at org.'

  Scenario Outline: Data-driven bill pay validation - Edge cases
    Given path 'billpay'
    And param accountId = <accountIdParam>
    And param amount = <amountParam>
    And params { payeeName: '#(payeeName)', 'address.street': '#(payeeAddress)', 'address.city': '#(payeeCity)', 'address.state': '#(payeeState)', 'address.zipCode': '#(payeeZipCode)', phoneNumber: '#(payeePhone)', accountNumber: '#(payeeAccountNumber)' }
    When method POST
    Then status <expectedStatus>
    And match response contains '<expectedMessage>'
    
    # Validate error messages are descriptive
    And match response == '#string'
    And match response == '#? _.length > 10'

    Examples:
      | accountIdParam | amountParam | expectedStatus | expectedMessage |
      | 13344          | 0           | 400            | valid           |
      | 13344          | -50         | 400            | valid           |
      | 999999         | 100         | 400            | find account    |

  Scenario: Validate error schema consistency
    # Test with zero amount
    Given path 'billpay'
    And param accountId = accountId
    And param amount = 0
    And params { payeeName: '#(payeeName)', 'address.street': '#(payeeAddress)', 'address.city': '#(payeeCity)', 'address.state': '#(payeeState)', 'address.zipCode': '#(payeeZipCode)', phoneNumber: '#(payeePhone)', accountNumber: '#(payeeAccountNumber)' }
    When method POST
    Then status 400
    * def zeroAmountError = response
    * print 'Zero Amount Error:', zeroAmountError
    
    # Test with negative amount
    Given path 'billpay'
    And param accountId = accountId
    And param amount = -100
    And params { payeeName: '#(payeeName)', 'address.street': '#(payeeAddress)', 'address.city': '#(payeeCity)', 'address.state': '#(payeeState)', 'address.zipCode': '#(payeeZipCode)', phoneNumber: '#(payeePhone)', accountNumber: '#(payeeAccountNumber)' }
    When method POST
    Then status 400
    * def negativeAmountError = response
    * print 'Negative Amount Error:', negativeAmountError
    
    # Test with non-existent account
    Given path 'billpay'
    And param accountId = 999999
    And param amount = 50
    And params { payeeName: '#(payeeName)', 'address.street': '#(payeeAddress)', 'address.city': '#(payeeCity)', 'address.state': '#(payeeState)', 'address.zipCode': '#(payeeZipCode)', phoneNumber: '#(payeePhone)', accountNumber: '#(payeeAccountNumber)' }
    When method POST
    Then status 400
    * def accountNotFoundError = response
    * print 'Account Not Found Error:', accountNotFoundError
    
    # Validate all errors are strings and descriptive
    And match zeroAmountError == '#string'
    And match negativeAmountError == '#string'
    And match accountNotFoundError == '#string'