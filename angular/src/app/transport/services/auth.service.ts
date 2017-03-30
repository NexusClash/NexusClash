import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';

@Injectable()
export class AuthService extends PacketService {

  isHandlerFor(packet: Packet): boolean {
    return ["authentication_request"].includes(packet.type);
  }

  handle(packet: Packet): void {
    this.send(
      <Packet>{type: "connect", char_id: "124"}, // TODO handle this better
      <Packet>{type: "refresh_map"},
      <Packet>{type: "sync_messages"}
    );
  }
}
