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
    error: (error) => console.error(error),
    complete: () => console.error("Stream closed.")
  }

  protected relevantPackets = this.socketService.rxPackets
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
    console.error("Unhandled packet");
    console.log(packet)
  }

  protected send(...packets: Packet[]): void {
    this.socketService.send(packets).subscribe();
  }

  protected isHandlerFor(packet: Packet): boolean{
    return this.handledPacketTypes.includes(packet.type);
  }
}
