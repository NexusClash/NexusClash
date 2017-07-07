import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/startWith';
import 'rxjs/add/operator/take';

import { Character } from '../models/character';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class CharacterService extends PacketService {

  private characterCache = new Map<number, Character>();
  characters = new Subject<Map<number, Character>>();
  myself = new Subject<Character>();
  myId: number;

  handledPacketTypes = ['self', 'character', 'remove_character'];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    if('remove_character' == packet.type){
      this.removeCharacter(packet);
    } else {
      this.upsertCharacter(packet);
    }
    this.characters.next(this.characterCache);
  }

  charactersAt(locationId: string): Observable<Character[]> {
    return this.characters
      .startWith(this.characterCache)
      .map(map => Array.from(map.values())
        .filter(character => character.locationId == locationId)
      );
  }

  character(characterId: number): Observable<Character> {
    return this.characters
      .startWith(this.characterCache)
      .map(map => map.get(characterId));
  }

  visibleTiles(viewDistance?: number): Observable<string[]> {
    viewDistance = viewDistance || 2;
    return this.myself
      .map(character => {
        let tilesPerSide = 1 + 2 * viewDistance;
        let totalTiles = tilesPerSide ** 2;
        let minX = character.x - viewDistance;
        let minY = character.y - viewDistance;
        return new Array(totalTiles).fill('').map((_,i) => {
          let x = minX + i % tilesPerSide;
          let y = minY + Math.floor(i / tilesPerSide);
          return [x,y,character.z,character.plane].join(',');
        });
      })
      .share();
  }

  doWhenCharacterIsKnown(callback: Function): void {
    if(this.myId != null) {
      callback();
    } else {
      this.myself.take(1).subscribe(() => callback());
    }
  }

  private upsertCharacter(packet: Packet): Character {
    let characterFromPacket = packet['character'];
    let id = +characterFromPacket['id'];
    let isMe = 'self' == packet.type;
    let existingCharacter = this.characterCache.has(id)
      ? this.characterCache.get(id)
      : new Character();
    let updatedCharacter = Object.assign(existingCharacter, characterFromPacket);
    this.characterCache.set(id, updatedCharacter);
    if(isMe || this.myId == id) {
      this.myId = id;
      this.myself.next(updatedCharacter);
    }
    return updatedCharacter;
  }

  private removeCharacter(packet: Packet): void {
    this.characterCache.delete(+packet['char_id']);
  }
}
