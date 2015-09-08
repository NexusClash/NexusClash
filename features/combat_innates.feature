Feature: Combat With Innates

  Scenario: Sally hits Joe with a club. She gains XP!
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Sally has 0 XP
    When Sally attacks Joe with their weapon
    Then Sally should have 5 XP

  Scenario: Sally kills Joe and gains more XP!
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 100%)
    And Sally has 0 XP
    And Joe has 5 HP
    When Sally attacks Joe with their weapon
    Then Sally should have 6 XP

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

  Scenario: Sally should be unable to attack without AP
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 50%)
    And Joe has 40 HP
    And Sally has 0 AP
    When Sally attacks Joe with their weapon
    Then Sally should have 0 AP
    And Joe should have 40 HP

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

  Scenario: Sally has a skill that makes her punches always hit
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate melee attack (5 impact @ 0%)
    And Sally has a skill that increases hit % of melee weapons by 100%
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 35 HP

  Scenario: Sally has a skill that makes her punches always hit but she uses a sling
    Given a character named Joe
    And a character named Sally
    Given Sally has an innate ranged attack (5 impact @ 0%)
    And Sally has a skill that increases hit % of melee weapons by 100%
    And Joe has 40 HP
    When Sally attacks Joe with their weapon
    Then Joe should have 40 HP