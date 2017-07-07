import { Component } from '@angular/core';

import { AbilityService } from '../../services/ability.service';
import { BasicService } from '../../services/basic.service';

@Component({
  selector: 'app-basic-actions',
  templateUrl: './basic-actions.component.html',
  styleUrls: ['./basic-actions.component.css']
})
export class BasicActionsComponent {

  constructor(
    private basicService: BasicService,
    private abilityService: AbilityService
  ) { }
}
