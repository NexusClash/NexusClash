import { Component, Input } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';

import { Character } from '../../transport/models/character';
import { CharacterService } from '../../transport/services/character.service';
import { Tile } from '../../transport/models/tile';

@Component({
  selector: 'app-description',
  templateUrl: './description.component.html',
  styleUrls: ['./description.component.css']
})
export class DescriptionComponent {

  @Input() character: Character;
  @Input() tile: Tile;

  get others(): Observable<Character[]> {
    return this.character
      ? this.characterService.charactersAt(this.character.locationId)
          .map(characters => characters
            .filter(character => character.id != this.character.id))
      : Observable.of([]);
  }

  constructor(
    private characterService: CharacterService
  ) { }

  selectTarget(character: Character) {
    this.characterService.selectTarget(character.id);
  }
}
