@parabank_loan
Feature: Loan Request with Risk Assessment

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def fromAccountId = 13344

  Scenario: Successful loan request with valid down payment
    # Step 1: Request loan with adequate down payment
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = 10000
    And param downPayment = 2000
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200
    
    # Step 2: Validate response structure
    And match response ==
    """
    {
      loanProviderName: '#string',
      responseDate: '#string',
      approved: '#boolean'
    }
    """
    
    # Step 3: Validate responseDate is ISO-8601 format
    * def responseDate = response.responseDate
    * print 'Response Date:', responseDate
    And match responseDate == '#string'
    And match responseDate != null
    And match responseDate == '#? _.length > 0'
    
    # Step 4: Validate ISO-8601 date pattern (YYYY-MM-DD or full ISO timestamp)
    * def iso8601Pattern = '^\\d{4}-\\d{2}-\\d{2}'
    And match responseDate == '#regex ' + iso8601Pattern
    
    # Step 5: Validate loan was approved
    And match response.approved == true
    And match response.loanProviderName == '#string'

  Scenario Outline: Loan risk assessment with different profiles
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = <loanAmount>
    And param downPayment = <downPaymentAmount>
    And param fromAccountId = fromAccountId
    When method POST
    Then status 200
    
    # Validate response date format
    And match response.responseDate == '#string'
    And match response.responseDate == '#regex ^\\d{4}-\\d{2}-\\d{2}'
    
    # Validate approval logic based on down payment ratio
    And match response.approved == <expectedApproval>
    
    # Log the decision
    * print 'Loan Amount:', <loanAmount>, 'Down Payment:', <downPaymentAmount>, 'Approved:', response.approved

    Examples:
      | loanAmount | downPaymentAmount | expectedApproval |
      | 5000       | 1000              | true             |
      | 10000      | 2500              | true             |
      | 20000      | 500               | false            |
      | 50000      | 5000              | false            |

  Scenario: Validate loan response date is never null
    # Test multiple loan requests
    * def loanRequests = [{ amount: 1000, down: 200 }, { amount: 5000, down: 1000 }, { amount: 15000, down: 1500 }]
    
    * def validateLoanDate =
    """
    function(loanData) {
      var result = karate.call('classpath:org/udea/parabank/Loan.feature@requestLoan', loanData);
      karate.log('Response:', result.response);
      karate.match(result.response.responseDate, '#string');
      karate.match(result.response.responseDate, '#? _ != null');
      return result.response;
    }
    """
    
    * def responses = karate.map(loanRequests, validateLoanDate)
    * print 'All Responses:', responses
    
    # Validate all responses have valid dates
    And match each responses[*].responseDate == '#string'
    And match each responses[*].responseDate == '#? _ != null'

  @requestLoan
  Scenario: Helper scenario for loan request
    Given path 'requestLoan'
    And param customerId = 12212
    And param amount = amount
    And param downPayment = down
    And param fromAccountId = fromAccountId
    When method POST