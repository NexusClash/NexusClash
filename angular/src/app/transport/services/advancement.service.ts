import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { Packet } from '../models/packet';
import { SocketService } from './socket.service';

@Injectable()
export class AdvancementService extends PacketService {

  handledPacketTypes = ["skill_tree"];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  getSkillTree(): void {
    this.send(new Packet("request_skill_tree"));
  }
}
