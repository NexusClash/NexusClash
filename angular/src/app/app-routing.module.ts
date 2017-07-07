import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { AdvancementComponent } from './components/advancement/advancement.component';
import { AttackComponent } from './components/attack/attack.component';
import { ChangeClassComponent } from './components/change-class/change-class.component';
import { GameComponent } from './components/game/game.component';
import { InventoryComponent } from './components/inventory/inventory.component';

import { RefreshInventoryGuard } from './guards/refresh-inventory.guard';

const appRoutes: Routes = [
  {
    path: 'game/:id',
    children: [
      { path: '', component: GameComponent },
      { path: 'buy-skills', component: AdvancementComponent, outlet: 'popup' },
      { path: 'choose-class', component: ChangeClassComponent, outlet: 'popup' },
      { path: 'attack/:other_id', component: AttackComponent, outlet: 'popup'  },
      { path: 'inventory', component: InventoryComponent, outlet: 'popup', canActivate: [RefreshInventoryGuard] },
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
