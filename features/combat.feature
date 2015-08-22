Feature: Combat

  Scenario: Sally hits Joe with a club. It hurts!
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Joe is at 40 HP
    When Sally attacks Joe with her weapon
    Then Joe should be at 35 HP

  Scenario: Sally misses Joe with an attack
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 0%)
    And Joe is at 40 HP
    When Sally attacks Joe with her weapon
    Then Joe should be at 40 HP