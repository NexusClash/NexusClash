import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';

import { AuthService } from '../../transport/services/auth.service';

@Component({
  selector: 'app-game',
  templateUrl: './game.component.html',
  styleUrls: ['./game.component.css']
})
export class GameComponent implements OnInit {

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
