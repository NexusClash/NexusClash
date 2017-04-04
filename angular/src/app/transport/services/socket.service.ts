import { Injectable } from '@angular/core';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'
import { Observable } from 'rxjs/Observable';
import { Observer } from 'rxjs/Observer';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/observable/from';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/merge';
import 'rxjs/add/operator/mergeAll';
import 'rxjs/add/operator/share';

import { Packet } from '../models/packet';

@Injectable()
export class SocketService {

  private socketUrl = 'ws://localhost:4567/42'
  private socket = new $WebSocket(this.socketUrl);

  public rxPackets: Observable<Packet> = this.socket
    .getDataStream()
    .map(message => Observable.from<Packet>(JSON.parse(message.data).packets))
    .mergeAll()
    .share()

  private txPackets: Subject<Packet> = new Subject();

  public allPackets: Observable<any[]> = this.rxPackets
    .map(msg => ({class:'recieved', packet: msg}))
    .merge(this.txPackets
      .map(msg => ({class: 'sent', packet: msg})))
    .scan((packets, packet) => packets.concat([packet]), [])
    .share();

  send(packets: Packet[]): any {
    packets.forEach(packet => this.txPackets.next(packet));
    return this.socket.send({packets: packets});
  }
}
