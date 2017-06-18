import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { CharacterService } from './character.service';
import { Packet } from '../models/packet';
import { Learnable } from '../models/learnable';
import { TierUp } from '../models/tier-up';
import { SocketService } from './socket.service';

@Injectable()
export class AdvancementService extends PacketService {

  handledPacketTypes = ["skill_tree", "class_choices"];
  learnables: Learnable[] = [];
  classChoices: TierUp[] = [];

  constructor(
    protected socketService: SocketService,
    protected characterService: CharacterService,
  ) {
    super(socketService);
    this.characterService.doWhenCharacterIsKnown(() => this.refreshChoices());
  }

  refreshChoices(): void {
    this.send(new Packet("request_skill_tree"));
    this.send(new Packet("request_classes"));
  }

  purchase(id: number): void {
    this.send(new Packet("learn_skill", {id: id}));
  }

  protected handle(packet: Packet): void {
    if(packet.type == 'skill_tree'){
      this.learnables = packet['tree'];
    }
    if(packet.type == 'class_choices'){
      this.classChoices = packet['classes']
        .map(c => new TierUp(c));
    }
  }
}
