import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/startWith';
import 'rxjs/add/operator/take';

import { Attack } from '../models/attack';
import { Character } from '../models/character';
import { Message } from '../models/message';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class AttackService extends PacketService {

  private targetId: number;

  combatMessages = new Subject<Message>();
  possibleAttacks = new Subject<Attack[]>();

  handledPacketTypes = ["actions", "message"];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    switch(packet.type){
      case "actions":
        return this.handleActionPacket(packet);
      case "message":
        return this.handleMessagePacket(packet);
    }
  }

  selectTarget(characterId: number): void {
    this.targetId = characterId;
    this.send(new Packet('select_target', { char_id: characterId }));
  }

  attack(actionId: number): void {
    this.send(new Packet('attack', {
      target_type: 'character',
      target: this.targetId,
      weapon: actionId
    }));
  }

  private handleActionPacket(packet: Packet): void {

    let possibleAttacks = [];
    let attacks = packet["actions"].attacks;
    for(let attackId in attacks){
      let attack = attacks[attackId];
      attack["id"] = attackId;
      possibleAttacks.push(new Attack(attack));
    }
    this.possibleAttacks.next(possibleAttacks);
  }

  private handleMessagePacket(packet: Packet): void {
    let message = new Message(packet);
    if(message.class != "combat-attack"){
      return;
    }
    this.combatMessages.next(message);
  }
}
