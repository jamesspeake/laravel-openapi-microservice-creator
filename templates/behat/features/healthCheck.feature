Feature: Get {{name}} service health status
    As a devops engineer
    I need to know if the service is healthy or not
    So that I can alert and take action to investigate

    Scenario: Get healthy status
        When I request "/v{{version}}/{{name}}/health" using HTTP GET
        Then the response code is "200"
        And the response body contains JSON:
        """
        { "status": "healthy" }
        """
