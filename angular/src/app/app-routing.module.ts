import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { AdvancementComponent } from './components/advancement/advancement.component';
import { GameComponent } from './components/game/game.component';

const appRoutes: Routes = [
  {
    path: 'game/:id',
    children: [
      { path: '', component: GameComponent },
      { path: ':advancement', component: AdvancementComponent, outlet: 'popup' }
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
