import { Injectable } from '@angular/core';

import { Message } from '../models/message';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class MessageService extends PacketService {

  messages: Message[] = [];

  handledPacketTypes = ["message"];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    let message = Object.assign(new Message(), packet);
    this.messages = [message].concat(this.messages);
  }
}
