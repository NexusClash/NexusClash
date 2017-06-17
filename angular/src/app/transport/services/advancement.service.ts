import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { PacketService } from './packet.service';
import { CharacterService } from './character.service';
import { Packet } from '../models/packet';
import { Learnable } from '../models/learnable';
import { SocketService } from './socket.service';

@Injectable()
export class AdvancementService extends PacketService {

  handledPacketTypes = ["skill_tree"];
  learnables: Learnable[] = [];

  constructor(
    protected socketService: SocketService,
    protected characterService: CharacterService,
  ) {
    super(socketService);
    this.characterService.doWhenCharacterIsKnown(() => this.getSkillTree());
  }

  getSkillTree(): void {
    this.send(new Packet("request_skill_tree"));
  }

  purchase(id: number): void {
    this.send(new Packet("learn_skill", {id: id}));
  }

  protected handle(packet: Packet): void {
    this.learnables = packet['tree'];
  }

  private flattenTree(learnable: Learnable): Learnable[] {
    let meAndMine = [learnable].concat((learnable.children || [])
      .map(child => this.flattenTree(child))
      .reduce((all, learnables) => all.concat(learnables), []));
    return meAndMine;
  }
}
