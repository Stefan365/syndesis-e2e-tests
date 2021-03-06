# @sustainer: avano@redhat.com

@rest
@integration-db-to-db-monitoring
@database
@datamapper
Feature: Integration - Monitoring

  Background: Clean application state
    Given clean application state
      And remove all records from table "todo"
      And remove all records from table "contact"

  Scenario: Metrics and activity log
    When inserts into "contact" table
      | Josef3 | Stieranka | Istrochem | db |
      And create start DB periodic sql invocation action step with query "SELECT * FROM CONTACT" and period "5000" ms
      And add a split step
      And add log step
      And start mapper definition with name: "mapping 1"
      And MAP using Step 2 and field "/first_name" to "/<>/task"
      And create finish DB invoke sql action step with query "INSERT INTO TODO (task, completed) VALUES (:#task, 0)"
    Then create integration with name: "DB to DB logs rest test"
      And wait for integration with name: "DB to DB logs rest test" to become active
      And validate that number of all todos with task "Josef3" is greater than "1"
      And check that pod "db-to-db-logs-rest-test" logs contain string "Josef3"
      And validate that number of all messages through integration "DB to DB logs rest test" is greater than 3, period in ms: 5000
