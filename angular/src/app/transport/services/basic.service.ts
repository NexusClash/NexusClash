import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';
import { SocketService } from './socket.service';

@Injectable()
export class BasicService extends PacketService {

  handledPacketTypes = [];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  hide(): void {
    this.send(new Packet("hide"));
  }

  search(): void {
    this.send(new Packet("search"));
  }

  speech(message: string): void {
    this.send(new Packet('speech', {message: message}));
  }
}
