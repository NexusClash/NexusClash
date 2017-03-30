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
  private socket: $WebSocket;
  private stream: Observable<any>;

  private rxObserver: Observer<Packet>;
  public rxPackets: Observable<Packet> = Observable
    .create(observer => this.rxObserver = observer)
    .share();

  private txObserver: Observer<Packet>;
  private txPackets: Observable<Packet> = Observable
    .create(observer => this.txObserver = observer)
    .share();

  public allPackets: Observable<any[]> = this.txPackets
    .map(msg => ({class: 'sent', packet: msg}))
    .merge(this.rxPackets
      .map(msg => ({class:'recieved', packet: msg})))
    .scan((packets, packet) => packets.concat([packet]), [])
    .share();

  constructor() {
    this.rxPackets.subscribe();
    this.txPackets.subscribe();
    this.allPackets.subscribe();
  }

  private ensuredStream(): Observable<any> {
    if(this.stream) {
      return this.stream;
    }
    this.socket = new $WebSocket(this.socketUrl);
    return this.stream = this.socket.getDataStream().asObservable();
  }

  private streamInProgress: Observable<Packet>;
  public packetStream(): Observable<Packet> {
    return this.streamInProgress
      ? this.streamInProgress
      : this.ensuredStream()
        .map(message => Observable.from<Packet>(JSON.parse(message.data).packets))
        .mergeAll()
        .multicast(
          () => this.streamInProgress = new Subject<Packet>()
        )
        .refCount()
        .do(packet => this.rxObserver.next(packet));
  }

  send(packets: Packet[]): any {
    packets.forEach(packet => this.txObserver.next(packet));
    return this.socket.send({packets: packets});
  }
}
