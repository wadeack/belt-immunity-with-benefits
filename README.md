Belt Immunity With Benefits
===================================================================================================

About the mod:
---------------------------------------------------------------------------------------------------

Mod adds a speed boost when running along transport belts while equipped with belt immunity
equipment. No new entities are introduced — the vanilla grid equipment has been modified to transfer
belt speed to the player character.

Technical notes:
---------------------------------------------------------------------------------------------------

Player position change event handler works in such a way that, when powered belt immunity equipment
is active and the player is on a belt, additional speed is applied. Because of this event handling,
slight delays may occur between meeting the conditions and the speed boost being applied.

Limitations:
---------------------------------------------------------------------------------------------------

* Does not affect vehicles (automobile, tank, etc..).
* Speed is only added in the belt’s orientation (straight direction). Diagonal boosts are not
  supported.

License
---------------------------------------------------------------------------------------------------

This project is licensed under the terms of the [MIT License](LICENSE).
