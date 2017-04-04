import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';

@Injectable()
export class AuthService extends PacketService {

  characterId: number;

  handledPacketTypes = ["authentication_request"];

  handle(packet: Packet) {
    this.connect();
  }

  public connect(): void {
    this.send(
      new Packet("connect", { char_id: this.characterId }),
      new Packet("refresh_map"),
      new Packet("sync_messages")
    );
  }
}
