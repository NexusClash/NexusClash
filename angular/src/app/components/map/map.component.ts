import { Component, OnInit } from '@angular/core';

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

  constructor(
    private tileService: TileService,
    private characterService: CharacterService
  ) { }

  get character(): Character {
    return this.characterService.character;
  }

  tilesInOrder(): Tile[] {
    const viewDistance = 2;
    let minX = this.character.x - viewDistance;
    let maxX = this.character.x + viewDistance;
    let minY = this.character.y - viewDistance;
    let maxY = this.character.y + viewDistance;
    let tiles = [];
    for(let y = minY; y <= maxY; y++){
      for(let x = minX; x <= maxX; x++){
        tiles.push(this.tileService.tile(
          x, y, this.character.z,
          this.character.plane
        ));
      }
    }
    return tiles;
  }

  move(tile) {
    this.tileService.move(tile.x, tile.y, tile.z);
  }
}
