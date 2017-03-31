import { Component } from '@angular/core';
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

  typeFilter: string;
  contentFilter: string;

  constructor(
    private socketService: SocketService
  ) { }

  shouldHide(packet: any): boolean {
    return this.filteredOutByType(packet)
        || this.filteredOutByContent(packet);
  }

  private filteredOutByType(packet: any): boolean {
    return this.typeFilter
      && this.typeFilter.trim()
      && this.typeFilter.split(/\s+/)
        .every((typeSubStr) => !packet.type.includes(typeSubStr));
  }

  private filteredOutByContent(packet: any): boolean {
    return this.contentFilter
      && !JSON.stringify(packet).toLowerCase().includes(this.contentFilter.toLowerCase());
  }
}
