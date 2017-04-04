import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/startWith';

import { Character } from '../models/character';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class CharacterService extends PacketService {

  private characterCache = new Map<number,Character>();
  characters = new Subject<Map<number, Character>>();
  myself = new Subject<Character>();

  handledPacketTypes = ['self', 'character', 'remove_character'];

  handle(packet: Packet): void {
    if('remove_character' == packet.type){
      this.removeCharacter(packet);
    } else {
      this.upsertCharacter(packet);
    }
    this.characters.next(this.characterCache);
  }

  charactersAt(x: number, y: number, z: number): Observable<Character[]> {
    return this.characters
      .startWith(this.characterCache)
      .map(map => Array.from(map.values())
        .filter(character =>
          character.x == x &&
          character.y == y &&
          character.z == z
        )
      );
  }

  selectTarget(characterId: number): void {
    this.send(new Packet('select_target', { char_id: characterId }));
  }

  private upsertCharacter(packet: Packet): Character {
    let characterFromPacket = packet['character'];
    let id = +characterFromPacket['id']
    let isMe = 'self' == packet.type;
    let existingCharacter = this.characterCache.has(id)
      ? this.characterCache.get(id)
      : new Character();
    let updatedCharacter = Object.assign(existingCharacter, characterFromPacket);
    this.characterCache.set(id, updatedCharacter);
    if(isMe) {
      this.myself.next(updatedCharacter);
    }
    return updatedCharacter;
  }

  private removeCharacter(packet: Packet): void {
    this.characterCache.delete(+packet['char_id']);

  }
}
