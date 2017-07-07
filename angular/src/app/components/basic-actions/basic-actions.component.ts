import { Component } from '@angular/core';

import { BasicService } from '../../services/basic.service';

@Component({
  selector: 'app-basic-actions',
  templateUrl: './basic-actions.component.html',
  styleUrls: ['./basic-actions.component.css']
})
export class BasicActionsComponent {

  constructor(
    private basicService: BasicService
  ) { }
}
