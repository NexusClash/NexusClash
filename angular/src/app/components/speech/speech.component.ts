import { Component } from '@angular/core';

import { BasicService } from '../../services/basic.service';

@Component({
  selector: 'app-speech',
  templateUrl: './speech.component.html',
  styleUrls: ['./speech.component.css']
})
export class SpeechComponent  {

  text: string;

  constructor(
    private basicService: BasicService
  ) { }

  speak(): void {
    this.basicService.speech(this.text);
    this.text = '';
  }

}
