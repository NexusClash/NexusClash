Feature: Activated Items

  Scenario: Joe uses book and then has no items
    Given a character named Joe
    Given Joe has a book
    When Joe uses their item
    Then Joe should have 0 items

  Scenario: Joe has two books, uses a book and still has his other book
    Given a character named Joe
    Given Joe has a book
    And Joe has a book
    When Joe uses their item
    Then Joe should have 1 items

  Scenario: Joe reads a book for XP
    Given a character named Joe
    Given Joe has a book
    And Joe has a book
    When Joe uses their item
    Then Joe should have 1 items

  Scenario: Reading a book costs AP
    Given a character named Joe
    Given Joe has a book
    And Joe has 2 AP
    And Joe has 0 XP
    When Joe uses their item
    Then Joe should have 1 AP
    And Joe should have 10 XP

  Scenario: You can't read a book without AP
    Given a character named Joe
    Given Joe has a book
    And Joe has 0 AP
    And Joe has 0 XP
    When Joe uses their item
    Then Joe should have 1 items
    And Joe should have 0 XP

  Scenario: Healing potions should not heal above maximum HP
    Given a character named Joe
    Given Joe has a healing potion
    And Joe has 42 HP
    When Joe uses their item
    Then Joe should have 0 items
    And Joe should have 50 HP

  Scenario: Healing potions should not reduce HP above maximum
    Given a character named Joe
    Given Joe has a healing potion
    And Joe has 420 HP
    When Joe uses their item
    And Joe should have 420 HP
