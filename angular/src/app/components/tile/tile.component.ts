import { Component, EventEmitter, Input, Output } from '@angular/core';

import { Tile } from '../../transport/models/tile';

@Component({
  selector: 'app-tile',
  templateUrl: './tile.component.html',
  styleUrls: ['./tile.component.css']
})
export class TileComponent {

  @Input() tile: Tile;
  @Output() move = new EventEmitter<Tile>();

  get titleText() {
    return !!this.tile
      ? this.getTitleFromTile(this.tile)
      : "Void";
  }

  getTitleFromTile(tile): string {
    let title = (tile.name || "") +
      " (" + tile.x + ", " + tile.y;
    //TODO send tile.planeName from server or retrieve it here.
    if(tile.type) {
      title += ", a " + tile.type;
    }
    title += ") [ " + tile.occupants +" ]";
    return title;
  }

  classesFromTile(tile): string {
    let classes = ["tile"];
    if(!tile || tile.type == "Void")
      classes.push("void");
    return classes.join(" ");
  }
}
