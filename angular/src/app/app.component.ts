import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs/Observable';
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
  messageStream: any[] = [];
  get character(): Character {
    return this.characterService.character;
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
     let messageStream = this.socket.getDataStream();
     messageStream.subscribe(
       (message) => this.handleMesssage(message),
         (error) => this.handleError(error),
              () => alert('stream complete')
     );
  }

  handleError(error: any): void {
    console.error(error);
  }

  handleMesssage(message: MessageEvent): void {
    let data = JSON.parse(message.data);
    for (let packet of data.packets) {
      this.messageStream.push(packet);
      this.handlePacket(packet);
    }
  }

  handlePacket(packet: Packet): void {
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
