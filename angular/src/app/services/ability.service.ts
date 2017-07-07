import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'
import { Subject } from 'rxjs/Subject';

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';
import { SocketService } from './socket.service';

@Injectable()
export class AbilityService extends PacketService {

  handledPacketTypes = ["character"];
  abilitiesCache: {status_id: number, name: string}[] = [];
  abilities: Subject<{status_id: number, name: string}[]> = new Subject<{status_id: number, name: string}[]>()

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    console.log(packet["character"]["abilities"])
    let character = packet["character"];
    if(character["abilities"]){
      this.abilitiesCache = character["abilities"]
    }
    this.abilities.next(this.abilitiesCache);
  }

  useAbility(statusId: number): void {
    this.send(new Packet('activate_self', { status_id: statusId }));
  }
}
