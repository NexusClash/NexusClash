import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';

@Injectable()
export class BasicService extends PacketService {

  isHandlerFor(packet: Packet): boolean {
    return false;
  }

  handle(packet: Packet): void {
    throw("Basic service does not recieve packets");
  }

  hide(): void {
    this.send(new Packet("hide"));
  }

  search(): void {
    this.send(new Packet("search"));
  }
}
