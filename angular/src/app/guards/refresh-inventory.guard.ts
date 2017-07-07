import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { Observable } from 'rxjs/Observable';

import { Item } from '../models/item';
import { InventoryService } from '../services/inventory.service';

@Injectable()
export class RefreshInventoryGuard implements CanActivate {

  constructor(
    private inventoryService: InventoryService
  ) {}

  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): boolean {
    this.inventoryService.refresh();
    return true;
  }
}
