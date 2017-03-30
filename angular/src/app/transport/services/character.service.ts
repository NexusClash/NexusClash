import { Injectable } from '@angular/core';

import { Character } from '../models/character';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class CharacterService extends PacketService {

  character: Character;

  constructor(
    socketService: SocketService
  ) {
    super(socketService);
  }

  isHandlerFor(packet: Packet): boolean {
    return ["self","character"].includes(packet.type);
  }

  handle(packet: Packet): void {
    this.character = this.character || new Character();
    let characterFromPacket = packet["character"];
    if(characterFromPacket
      && (!this.character.id
        || characterFromPacket.id == this.character.id)){
      this.character = Object.assign(this.character, characterFromPacket);
    }
  }
}
