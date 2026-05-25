@parabank_billpay
Feature: Bill Pay Robustness and Exception Handling

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def accountId = 13344

  Scenario: Bill pay with amount greater than balance
    Given path 'accounts', accountId
    When method GET
    Then status 200

    * def currentBalance = response.balance
    * def excessiveAmount = currentBalance + 1000

    Given path 'billpay'
    And param accountId = accountId
    And param amount = excessiveAmount
    And request
    """
    {
      "name": "Utility Company",
      "address": {
        "street": "Main Street",
        "city": "Medellin",
        "state": "Antioquia",
        "zipCode": "050001"
      },
      "phoneNumber": "3001234567",
      "accountNumber": 99999
    }
    """
    When method POST
    Then status 200

    # Validate no internal server error
    And match responseStatus != 500

    # Validate no stack trace exposed
    And match response !contains 'Exception'
    And match response !contains 'at com.'

  Scenario Outline: Validate edge case amounts
    Given path 'billpay'
    And param accountId = accountId
    And param amount = <amount>
    And request
    """
    {
      "name": "Utility Company",
      "address": {
        "street": "Main Street",
        "city": "Medellin",
        "state": "Antioquia",
        "zipCode": "050001"
      },
      "phoneNumber": "3001234567",
      "accountNumber": 99999
    }
    """
    When method POST
    Then status 200

    And match responseStatus != 500
    And match response !contains 'Exception'

    * print 'Response:', response

    Examples:
      | amount |
      | 0      |
      | -50    |
      | 999999 |