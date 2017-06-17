import { Component, EventEmitter, Input, Output } from '@angular/core';

import { Learnable } from '../transport/models/learnable';

@Component({
  selector: 'app-learnable',
  templateUrl: './learnable.component.html',
  styleUrls: ['./learnable.component.css']
})
export class LearnableComponent {

  @Input() learnable: Learnable;
  @Output() learn = new EventEmitter<number>();

  private doLearn(id) {
    this.learn.emit(id || this.learnable.id);
  }
}
