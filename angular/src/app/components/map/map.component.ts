import { Component, Input } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/combineLatest';
import 'rxjs/add/operator/switchMap';

import { Character } from '../../transport/models/character';
import { CharacterService } from '../../transport/services/character.service';
import { Tile } from '../../transport/models/tile';
import { TileService } from '../../transport/services/tile.service';

@Component({
  selector: 'app-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.css']
})
export class MapComponent {


  @Input() character: Character;
  viewableCoordinates = this.characterService.visibleTiles();

  constructor(
    private tileService: TileService,
    private characterService: CharacterService
  ) { }

  move(tile: Tile): void {
    if(tile.x == this.character.x
    && tile.y == this.character.y)
      tile.z = (tile.z + 1) % 2;
    this.tileService.move(tile.x, tile.y, tile.z);
  }
}
