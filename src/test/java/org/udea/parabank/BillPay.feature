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

    And match responseStatus != 500

    * def responseText = response + ''

    And match responseText !contains 'Exception'
    And match responseText !contains 'at com.'

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

    * def responseText = response + ''

    And match responseText !contains 'Exception'
    And match responseText !contains 'at com.'

    * print 'Response:', response

    Examples:
      | amount |
      | 0      |
      | -50    |
      | 999999 |