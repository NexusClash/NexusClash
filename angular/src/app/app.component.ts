import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/multicast';
import { Subject } from 'rxjs/Subject';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { Character } from './packets/character';
import { Message } from './packets/message';
import { Packet } from './packets/packet';
import { PacketHandler } from './packets/packet-handler';
import { CharacterService } from './packets/services/character.service';
import { MessageService } from './packets/services/message.service';
import { TileService } from './packets/services/tile.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  socketUrl= 'ws://localhost:4567/42'
  socket: $WebSocket;
  stream: Observable<any>;
  messageStream: any[] = [];
  get character(): Character {
    return this.characterService.character;
  }
  get async_character(): Observable<Character> {
    return this.packetStream
      .filter(packet => this.characterService.isHandlerFor(packet))
      .map(packet => Object.assign(new Character(), packet["character"]))
      .first();
  }
  get xs(): number[] {
    let x = this.character.x;
    return [x - 2, x - 1, x, x + 1, x + 2];
  }
  get ys(): number[] {
    let y = this.character.y;
    return [y - 2, y - 1, y, y + 1, y + 2];
  }
  get messages(): Message[] {
    return this.messageService.messages;
  }
  private packetHandlers: PacketHandler[] = [];

  constructor(
    private characterService: CharacterService,
    private messageService: MessageService,
    private tileService: TileService
  ){
    this.packetHandlers.push(characterService);
    this.packetHandlers.push(messageService);
    this.packetHandlers.push(tileService);
  }

  ngOnInit(): void {
    this.socket = new $WebSocket(this.socketUrl);
    this.stream = this.socket.getDataStream().asObservable();
    this.packetStream.subscribe(
      (packet) => this.handlePacket(packet),
       (error) => this.handleError(error),
            () => alert('stream complete'));
  }

  private streamInProgress: Observable<Packet>;
  get packetStream(): Observable<Packet> {
    return this.streamInProgress
      ? this.streamInProgress
      : this.stream
        .map(message => Observable.from(JSON.parse(message.data).packets))
        .mergeAll()
        .multicast(
          () => this.streamInProgress = new Subject<Packet>()
        )
        .refCount();
  }

  handleError(error: any): void {
    console.error(error);
  }

  handlePacket(packet: Packet): void {
    this.messageStream.push(packet);
    let handled = false;
    if(packet.type == "authentication_request") {
      let connectionPackets = {packets: [
        {type: "connect", char_id: "118"},
        {type: "refresh_map"},
        {type: "sync_messages"}
      ]};
      this.sendMessage(connectionPackets);
      handled = true;
    }
    for(let handler of this.packetHandlers) {
      if(handler.isHandlerFor(packet)){
        let packetBack = handler.handle(packet);
        if(packetBack) {
          this.sendPacket(packetBack);
        }
        handled = true;
      }
    }
    if(!handled) {
      console.log("Unhandled packet: ");
      console.log(packet);
    }
  }

  sendPacket(packet: any): void {
    this.sendMessage({packets:[packet]});
  }

  sendMessage(message: any): void {
    for(let packet of message.packets){
      this.messageStream.push(packet);
    }
    this.socket.send(message).subscribe();
  }
}
