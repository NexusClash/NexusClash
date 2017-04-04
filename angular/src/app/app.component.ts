import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { Observable } from 'rxjs/Rx';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/multicast';
import { Subject } from 'rxjs/Subject';
import { $WebSocket, WebSocketSendMode } from 'angular2-websocket/angular2-websocket'

import { AuthService } from './transport/services/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {

  showDebugMessages: Boolean = false;
  showPacketTraffic: Boolean = false;

  constructor(
    private authService: AuthService,
    private route: ActivatedRoute
  ){ }

  ngOnInit() {
    this.authService.characterId = +this.route.snapshot.params['id'];
  }
}
