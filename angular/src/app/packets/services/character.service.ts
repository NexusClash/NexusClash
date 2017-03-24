import { Packet } from '../packet';
import { PacketHandler } from '../packet-handler';
import { Character } from '../character';

export class CharacterService implements PacketHandler {

  character: Character;

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
