@parabank_loan
Feature: Loan Request with Risk Assessment

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def fromAccountId = 13344

  Scenario: Successful loan request with valid down payment
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = 10000
    And param downPayment = 2000
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200

    And match response contains
    """
    {
      loanProviderName: '#string',
      responseDate: '#string',
      approved: '#boolean'
    }
    """

    And match response.responseDate != null
    And match response.responseDate == '#regex ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?Z$'

  Scenario Outline: Loan risk assessment with different profiles
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = <loanAmount>
    And param downPayment = <downPaymentAmount>
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200

    And match response.responseDate != null
    And match response.responseDate == '#string'
    And match response.responseDate == '#regex ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?Z$'

    Examples:
      | loanAmount | downPaymentAmount |
      | 5000       | 1000              |
      | 10000      | 2500              |
      | 20000      | 500               |
      | 50000      | 5000              |

  Scenario: Validate loan response date is never null
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = 1000
    And param downPayment = 200
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200

    And match response.responseDate != null
    And match response.responseDate == '#string'
    And match response.responseDate == '#regex ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?Z$'
