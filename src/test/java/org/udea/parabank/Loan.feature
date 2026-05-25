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
    
    # Validate response structure (FLEXIBLE - acepta campos extras)
    And match response contains
    """
    {
      loanProviderName: '#string',
      responseDate: '#number',
      approved: '#boolean'
    }
    """
    
    # Validate responseDate exists and is a number (Unix timestamp)
    * def responseDate = response.responseDate
    * print 'Response Date (Unix timestamp):', responseDate
    And match responseDate == '#number'
    And match responseDate != null
    And match responseDate > 0
    
    # Validate loan provider exists
    And match response.loanProviderName == '#string'

  Scenario Outline: Loan risk assessment with different profiles
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = <loanAmount>
    And param downPayment = <downPaymentAmount>
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200
    
    # Validate response date is a number (Unix timestamp)
    And match response.responseDate == '#number'
    And match response.responseDate > 0
    
    # Log the decision
    * print 'Loan Amount:', <loanAmount>, 'Down Payment:', <downPaymentAmount>, 'Approved:', response.approved

    Examples:
      | loanAmount | downPaymentAmount |
      | 5000       | 1000              |
      | 10000      | 2500              |
      | 20000      | 500               |
      | 50000      | 5000              |

  Scenario: Validate loan response date is never null
    # Test with a single loan request
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = 1000
    And param downPayment = 200
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200
    
    # Validate responseDate exists, is not null, and is a number
    And match response.responseDate == '#number'
    And match response.responseDate != null
    And match response.responseDate > 0
    
    * print 'Response:', response