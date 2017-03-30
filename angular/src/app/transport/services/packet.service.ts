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

  constructor(
    private socketService: SocketService
  ) {
    this.socketService.packetStream()
      .filter(packet => this.isHandlerFor(packet))
      .subscribe(this.defaultObserver);
  }

  protected handleError(error: any): void {
    console.error(error);
  }

  protected send(...packets: Packet[]): void {
    this.socketService.send(packets).subscribe();
  }

  protected abstract isHandlerFor(packet: Packet): boolean;
  protected abstract handle(packet: Packet): void;
}
