import { Component, Input } from '@angular/core';

import { Character } from '../../transport/models/character';

@Component({
  selector: 'app-summary',
  templateUrl: './summary.component.html',
  styleUrls: ['./summary.component.css']
})
export class SummaryComponent {

  @Input() character: Character;

}
