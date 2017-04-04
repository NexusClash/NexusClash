import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';

@Injectable()
export class BasicService extends PacketService {

  handledPacketTypes = [];

  hide(): void {
    this.send(new Packet("hide"));
  }

  search(): void {
    this.send(new Packet("search"));
  }

  speech(message: text): void {
    this.send(new Packet('speech', {message: message}));
  }
}
