import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/startWith';
import 'rxjs/add/operator/take';

import { Attack } from '../models/attack';
import { ChargeAttack } from '../models/charge-attack';
import { Character } from '../models/character';
import { Message } from '../models/message';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class AttackService extends PacketService {

  private targetId: number;

  combatMessages = new Subject<Message>();
  availableAttacks = new Subject<Attack[]>();
  availableChargeAttacks = new Subject<ChargeAttack[]>();

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

  attack(actionId: number, chargeAttackId: number): void {
    var attackPacket = new Packet('attack', {
      target_type: 'character',
      target: this.targetId,
      weapon: actionId
    });
    if(chargeAttackId){
      attackPacket["charge_attack"] = chargeAttackId;
    }
    this.send(attackPacket);
  }

  private handleActionPacket(packet: Packet): void {
    this.deserializeAttacks(packet);
    this.deserializeChargeAttacks(packet);
  }

  private handleMessagePacket(packet: Packet): void {
    let message = new Message(packet);
    if(message.class != "combat-attack"){
      return;
    }
    this.combatMessages.next(message);
  }

  private deserializeAttacks(packet: Packet): void {
    let availableAttacks = [];
    let attacks = packet["actions"].attacks;
    for(let attackId in attacks){
      let attack = attacks[attackId];
      attack["id"] = attackId;
      availableAttacks.push(new Attack(attack));
    }
    this.availableAttacks.next(availableAttacks);
  }

  private deserializeChargeAttacks(packet: Packet): void {
    let availableChargeAttacks = [];
    let chargeAttacks = packet["actions"].charge_attacks;
    for(let chargeAttackId in chargeAttacks){
      let chargeAttack = chargeAttacks[chargeAttackId];
      chargeAttack["id"] = chargeAttackId;
      availableChargeAttacks.push(new ChargeAttack(chargeAttack));
    }
    this.availableChargeAttacks.next(availableChargeAttacks);
  }
}
