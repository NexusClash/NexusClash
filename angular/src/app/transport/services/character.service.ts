import { Injectable } from '@angular/core';

import { Character } from '../models/character';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class CharacterService extends PacketService {

  selfId: number;
  characters = new Map<number,Character>();

  get character(): Character {
    return this.selfId && this.characters.has(this.selfId)
      ? this.characters.get(this.selfId)
      : null;
  }

  constructor(
    socketService: SocketService
  ) {
    super(socketService);
  }

  isHandlerFor(packet: Packet): boolean {
    return ["self","character"].includes(packet.type);
  }

  handle(packet: Packet): void {
    let character: Character = Object.assign(new Character(), packet["character"]);
    this.characters.set(character.id, this.characters.has(character.id)
      ? Object.assign(this.characters.get(character.id), character)
      : character);
    if(packet.type == "self") {
      this.selfId = character.id;
    }
  }

  charactersAt(x: number, y: number, z: number): Character[] {
    return Array.from(this.characters.values()).filter(character =>
      character.x == x &&
      character.y == y &&
      character.z == z
    );
  }

  selectTarget(characterId: number): void {
    this.send(Object.assign(new Packet("select_target"),
      { char_id: characterId }
    ));
  }
}
