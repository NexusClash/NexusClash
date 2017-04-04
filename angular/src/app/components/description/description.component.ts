import { Component, Input } from '@angular/core';
import { Observable } from 'rxjs/Observable';

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

  @Input() character: Character;

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

  others(): Observable<Character[]> {
    return this.character
      ? this.characterService.charactersAt(
          this.character.x,
          this.character.y,
          this.character.z
        )
        .map(characters => characters
          .filter(character => character.id != this.character.id)
        )
      : Observable.of([]);
  }

  selectTarget(character: Character) {
    this.characterService.selectTarget(character.id);
  }
}
