import { Component } from '@angular/core';

import { Character } from '../../transport/models/character';
import { CharacterService } from '../../transport/services/character.service';
import { Tile } from '../../transport/models/tile';
import { TileService } from '../../transport/services/tile.service';

@Component({
  selector: 'app-description',
  templateUrl: './description.component.html',
  styleUrls: ['./description.component.css']
})
export class DescriptionComponent {

  get character(): Character {
    return this.characterService.character;
  }

  get tile(): Tile {
    return this.character
      ? this.tileService.tile(
        this.character.x,
        this.character.y,
        this.character.z,
        this.character.plane)
      : null;
  }

  constructor(
    private tileService: TileService,
    private characterService: CharacterService
  ) { }

  others(): Character[] {
    return this.character
      ? this.characterService.charactersAt(
        this.character.x,
        this.character.y,
        this.character.z)
        .filter(character => character.id != this.character.id)
      : [];
  }

  selectTarget(character: Character) {
    this.characterService.selectTarget(character.id);
  }
}
