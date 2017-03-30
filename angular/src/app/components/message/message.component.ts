import { Component, OnInit } from '@angular/core';

import { MessageService } from '../../transport/services/message.service';

@Component({
  selector: 'app-messages',
  templateUrl: './message.component.html',
  styleUrls: ['./message.component.css']
})
export class MessageComponent implements OnInit {

  constructor(
    private messageService: MessageService
  ) { }

  ngOnInit() {
  }

}
