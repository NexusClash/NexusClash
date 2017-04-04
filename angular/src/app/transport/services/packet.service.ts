import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/filter';

import { Packet } from '../models/packet';
import { SocketService } from './socket.service';

@Injectable()
export abstract class PacketService {

  protected defaultObserver = {
    next: (packet) => this.handle(packet),
    error: (error) => this.handleError(error),
    complete: () => this.handleError("Stream closed.")
  }

  protected relevantPackets = this.socketService.packetStream()
    .filter(packet => this.isHandlerFor(packet))
    .share();

  protected abstract handledPacketTypes: string[];

  constructor(
    private socketService: SocketService
  ) {
      this.relevantPackets.subscribe(this.defaultObserver);
  }

  protected handle(packet: Packet): void {
    // override to do something to every relevant packet
  }

  protected handleError(error: any): void {
    console.error(error);
  }

  protected send(...packets: Packet[]): void {
    this.socketService.send(packets).subscribe();
  }

  protected isHandlerFor(packet: Packet): boolean{
    return this.handledPacketTypes.includes(packet.type);
  }
}
