import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';

import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';
import { Tile } from '../models/tile';

@Injectable()
export class TileService extends PacketService {

  plane: number;
  tileCache = new Map<string, Tile>();
  tiles = new Subject<Map<string, Tile>>();

  handledPacketTypes = ["tile"];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    let tileFromPacket = packet['tile'];
    tileFromPacket['plane'] = tileFromPacket['plane'] || this.plane;
    let id = [tileFromPacket['x'],tileFromPacket['y'],tileFromPacket['z'],tileFromPacket['plane']].join(',');
    let existingTile = this.tileCache.has(id)
      ? this.tileCache.get(id)
      : new Tile();
    let updatedTile = Object.assign(existingTile, packet["tile"]);
    this.tileCache.set(updatedTile.id, updatedTile);
    this.plane = updatedTile.plane;
    this.tiles.next(this.tileCache);
  }

  tile(locationId: string): Observable<Tile> {
    return this.tiles
      .filter(map => map.has(locationId))
      .map(map => map.get(locationId))
      .startWith(this.tileCache.get(locationId) || null);
  }

  move(x: number, y: number, z: number) {
    this.send(new Packet("movement", { x: x, y: y, z: z }));
  }
}
