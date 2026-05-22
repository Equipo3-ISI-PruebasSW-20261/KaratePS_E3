@parabank_account
Feature: Get account information from ParaBank

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def customerId = '12212'


  Scenario:Validate customer accounts schema and financial integrity
    Given path 'customers',customerId, 'accounts'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/json'
    # Schema validation
    And match each response ==
    """
    {
      id: '#number',
      customerId: '#number',
      type: '#string',
      balance: '#number'
    }
    """

    # Validate allowed account types
    And match each response[*].type contains any ['CHECKING', 'SAVINGS']

    # Validate customerId consistency
    And match each response[*].customerId contains customerId

    # Financial integrity validation
    * def balances = response[*].balance
    * match each balances == '#? _ >= 0'
