Feature: Locations & Movement

  Scenario: Joe moves around the world
    Given a character named Joe
    And a tile at 1, 1, 0
    And a tile at 1, 2, 0
    Given Joe is at 1, 1, 0
    And Joe has 10 AP
    When Joe attempts to move to 1, 2, 0
    Then Joe should be at 1, 2, 0
    And 1, 1, 0 should have 0 occupants
    And 1, 2, 0 should have 1 occupants

  Scenario: Joe has no AP so he cannot move
    Given a character named Joe
    And a tile at 1, 1, 0
    And a tile at 1, 2, 0
    Given Joe is at 1, 1, 0
    And Joe has 0 AP
    When Joe attempts to move to 1, 2, 0
    Then Joe should be at 1, 1, 0
    And 1, 1, 0 should have 1 occupants
    And 1, 2, 0 should have 0 occupants

  Scenario: Death should remove you from a tile
    Given a character named Joe
    And a character named Sally
    And a tile at 1, 1, 0
    Given Joe is at 1, 1, 0
    And Sally is at 1, 1, 0
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Joe has 1 HP
    When Sally attacks Joe with their weapon
    Then 1, 1, 0 should have 1 occupants