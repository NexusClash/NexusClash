Feature: Effect::Regen

  Scenario: Joe is badly wounded and just drank a powerful delayed healing potion. Joe expects this potion to patch him up on the next AP tick.
    Given a character named Joe
    Given Joe is badly wounded
    And Joe is affected by extremely powerful regeneration
    When there is an AP tick
    Then Joe should be at full HP