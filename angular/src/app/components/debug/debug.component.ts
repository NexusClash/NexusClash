import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/count';
import 'rxjs/add/operator/scan';

import { SocketService } from '../../transport/services/socket.service';

@Component({
  selector: 'app-stream-debug',
  templateUrl: './debug.component.html',
  styleUrls: ['./debug.component.css']
})
export class DebugComponent {

  private show: Boolean = false;

  constructor(
    private socketService: SocketService
  ) { }

  ngOnInit() {
  }
}
