@parabank_login
Feature: Autenticación y Persistencia de Sesión en Parabank

  Background:
    * url baseUrl
    * header Accept = 'application/json'

  Scenario: Login exitoso - Validar respuesta 200 y esquema del usuario
    Given path 'login', 'john', 'demo'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response ==
    """
    {
       "id": '#number',
       "firstName": '#string',
       "lastName": '#string',
       "address": {
            "street": '#string',
            "city": '#string',
            "state": '#string',
            "zipCode": '#string'
        },
       "phoneNumber": '#string',
       "ssn": '#string'
    }
    """
    And match response.id == '#? _ > 0'
    And match response.firstName == '#? _.length > 0'

  Scenario: Validación técnica - JSESSIONID presente en Set-Cookie
    Given path 'login', 'john', 'demo'
    When method GET
    Then status 200
    * def setCookieHeader = responseHeaders['Set-Cookie']
    * print 'Set-Cookie Header:', setCookieHeader
    And match setCookieHeader == '#notnull'
    * def cookieString = setCookieHeader + ''
    And match cookieString contains 'JSESSIONID'

  Scenario: Seguridad - Credenciales incorrectas retornan 401 Unauthorized
    Given path 'login', 'invalidUser', 'wrongPassword'
    When method GET
    Then status 401
    And match response == '#string'
    And match response == '#? _.length > 0'

  Scenario: Seguridad - Password incorrecto para usuario válido retorna 401
    Given path 'login', 'john', 'wrongPassword'
    When method GET
    Then status 401

  Scenario: Persistencia de sesión - JSESSIONID reutilizable en petición subsiguiente
    # Paso 1: Login y captura de sesión
    Given path 'login', 'john', 'demo'
    When method GET
    Then status 200
    * def customerId = response.id
    * def rawCookie = responseHeaders['Set-Cookie']
    * def sessionCookie = rawCookie == null ? '' : (rawCookie + '').replace(/;.*/, '')
    * print 'Customer ID:', customerId
    * print 'Session Cookie:', sessionCookie

    # Paso 2: Reutilizar JSESSIONID en petición subsiguiente
    Given path 'customers', customerId, 'accounts'
    And header Cookie = sessionCookie
    When method GET
    Then status 200
    And match response == '#array'
    And match each response[*].customerId == customerId
