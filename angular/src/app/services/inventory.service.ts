import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';

import { Item } from '../models/item';
import { Packet } from '../models/packet';
import { CharacterService } from './character.service';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class InventoryService extends PacketService {

  totalWeight: number;
  maxWeight: number;
  itemsCache: Item[] = []
  items = new Subject<Item[]>();

  handledPacketTypes = ["inventory"];

  constructor(
    protected characterService: CharacterService,
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    this.totalWeight = packet["weight"];
    this.maxWeight = packet["weight_max"];
    switch(packet["list"]){
      case "clear":
        this.itemsCache = packet["items"].map(data => new Item(data));
        break;
      case "remove":
        this.itemsCache = this.itemsCache.filter(item => !packet["items"].includes(item.id))
        break;
    }
    this.items.next(this.itemsCache);
  }

  refresh(): void {
    this.characterService.doWhenCharacterIsKnown(() =>
      this.send(new Packet('refresh_inventory')));
  }

  useItem(itemId: number, statusId: number): void {
    this.send(new Packet('activate_item_self', {
      id: itemId,
      status_id: statusId
    }));
  }

  drop(itemId: number): void {
    this.send(new Packet('drop', { id: itemId }));
  }
}
