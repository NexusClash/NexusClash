import { Injectable } from '@angular/core';

import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';
import { Tile } from '../models/tile';

@Injectable()
export class TileService extends PacketService {

  constructor(
    socketService: SocketService
  ) {
    super(socketService);
  }

  tiles: Map<string,Tile> = new Map<string,Tile>();

  isHandlerFor(packet: Packet): boolean {
    return ["tile"].includes(packet.type);
  }

  handle(packet: Packet): void {
    if(packet.type == "tile"){
      let tile = Object.assign(new Tile(), packet["tile"]);
      this.tiles.set(tile.id, tile);
    }
  }

  tile(x: number, y: number, z: number, plane: number): Tile {
    let tile_id = [x, y, z, plane].join(",");
    return this.tiles.has(tile_id)
      ? this.tiles.get(tile_id)
      : null;
  }

  move(x: number, y: number, z: number) {
    this.send(Object.assign(
      new Packet("movement"),
      {
        x: x,
        y: y,
        z: z
      }
    ));
  }
}
