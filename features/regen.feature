Feature: Effect::Regen

  Scenario: Joe is badly wounded and just drank a powerful delayed healing potion. Joe expects this potion to patch him up on the next AP tick.
    Given a character named Joe
    Given Joe is badly wounded
    And Joe is affected by extremely powerful regeneration
    When there is an AP tick
    Then Joe should be at full HP

  Scenario: Joe is poisoned and should lose HP on every status tick.
    Given a character named Joe
    Given Joe has 40 HP
    And Joe is affected by a 3 HP per status tick poison
    When there is a status tick
    Then Joe should have 37 HP

  Scenario: Joe is both regenerating and poisoned. Both effects should trigger correctly.
    Given a character named Joe
    Given Joe has 25 HP
    And Joe is affected by a 3 HP per status tick poison
    And Joe is affected by a 4 HP per status tick regeneration
    When there is a status tick
    Then Joe should have 26 HP