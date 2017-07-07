import { Component, Input } from '@angular/core';

import { MessageService } from '../../services/message.service';

@Component({
  selector: 'app-messages',
  templateUrl: './message.component.html',
  styleUrls: ['./message.component.css']
})
export class MessageComponent {

  @Input() showDebugMessages: boolean = false;

  constructor(
    private messageService: MessageService
  ) { }
}
