import { Packet } from './packet';
import { $WebSocket } from 'angular2-websocket/angular2-websocket'

export interface PacketHandler {
  isHandlerFor(packet: Packet): boolean;
  handle(packet: Packet): void | Packet;
}
