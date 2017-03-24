import { Packet } from '../packet';
import { PacketHandler } from '../packet-handler';
import { Message } from '../message';

export class MessageService implements PacketHandler {

  messages: Message[] = [];

  isHandlerFor(packet: Packet): boolean {
    return ["message"].includes(packet.type);
  }

  handle(packet: Packet): void {
    let message = Object.assign(new Message(), packet);
    this.messages = [message].concat(this.messages);
  }
}
