import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { AdvancementComponent } from './components/advancement/advancement.component';
import { ChangeClassComponent } from './components/change-class/change-class.component';
import { GameComponent } from './components/game/game.component';
import { AttackComponent } from './components/attack/attack.component';

const appRoutes: Routes = [
  {
    path: 'game/:id',
    children: [
      { path: '', component: GameComponent },
      { path: 'buy-skills', component: AdvancementComponent, outlet: 'popup' },
      { path: 'choose-class', component: ChangeClassComponent, outlet: 'popup' },
      { path: 'attack/:other_id', component: AttackComponent, outlet: 'popup'  }
    ]
  }
];

@NgModule({
  imports: [
    RouterModule.forRoot(appRoutes)
  ],
  exports: [
    RouterModule
  ]
})
export class AppRoutingModule {}
