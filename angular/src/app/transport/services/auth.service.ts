import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { SocketService } from './socket.service';
import { Packet } from '../models/packet';

@Injectable()
export class AuthService extends PacketService {

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  characterId: number;

  handledPacketTypes = ["authentication_request"];

  handle(packet: Packet) {
    this.connect();
  }

  public connect(): void {
    console.log("connecting with character id");
    this.send(
      new Packet("connect", { char_id: this.characterId }),
      new Packet("refresh_map"),
      new Packet("sync_messages")
    );
  }
}
