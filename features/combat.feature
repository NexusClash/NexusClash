Feature: Combat

  Scenario: Sally hits Joe with a club. It hurts!
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 35 HP

  Scenario: Sally tries to hit Joe with a club but she has no AP
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Joe has 40 HP
    And Sally has 0 AP
    When Sally attacks Joe with their weapon
    Then Joe should have 40 HP

  Scenario: Sally attacks Joe, it should cost AP
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 50%)
    And Sally has 3 AP
    When Sally attacks Joe with their weapon
    Then Sally should have 2 AP

  Scenario: Sally misses Joe with an attack
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 0%)
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 40 HP

  Scenario: Sally tries to attack Joe but has no ammo
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate ammo-using ranged attack (5 impact @ 100%) loaded with 0 ammo
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 40 HP

  Scenario: Sally tries to attack Joe and has ammo
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate ammo-using ranged attack (5 impact @ 100%) loaded with 1 ammo
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 35 HP

  Scenario: Sally tries to attack Joe twice but only has enough ammo for 1 shot
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate ammo-using ranged attack (5 impact @ 100%) loaded with 1 ammo
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    And Sally attacks Joe with their weapon
    Then Joe should have 35 HP